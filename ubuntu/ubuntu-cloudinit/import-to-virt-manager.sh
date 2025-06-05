#!/bin/bash

# Use virt-install to automate creation of the VM in the virt-manager GUI
#
# To get help on any argument outside of the man pages:
# $ virt-install --${arg}=?
# For example:
# $ virt-install --boot=?
# For details on supported OS variants:
# $ virt-install --osinfo list
#
# For specifics from libvirt on both TPM and RNG devices, check the man pages then:
# https://libvirt.org/formatdomain.html#random-number-generator-device
# https://libvirt.org/formatdomain.html#tpm-device

vm_name=''
src_path=''
dest_path=''
vm_os=''
vm_vcpus='4'
vm_memory='8192' # 2048, 4096, 8192, 16384
vm_net='default'

if ! groups | grep -Pq '\blibvirt\b'; then
  echo "[*]$USER is not a member of the 'libvirt' group. Run: $ sudo usermod -aG libvirt $USER"
  exit
fi

if [[ "$vm_name" == '' ]]; then
  echo "[*]Please choose what this VM will be named in virt-manager."
  echo ""
  until [[ "$vm_name" =~ ^([a-zA-Z0-9._-]+){1,}$ ]]; do
    read -rp "[Enter a VM name]: " -e -i 'ubuntu22.04' vm_name
  done
fi

if [[ "$vm_os" == '' ]]; then
  echo "[*]Please set the os type for virt-manager, effectively the os version."
  echo ""
  until [[ "$vm_os" =~ ^([a-zA-Z0-9._-]+){1,}$ ]]; do
    read -rp "[ubuntu14.04,ubuntu22.04, ...]: " -e -i 'ubuntu22.04' vm_os
  done
fi

if [[ "$src_path" == '' ]]; then
  echo "[*]What is the name of the output directory containing the disk image file?"
  echo ""
  until [[ "$src_path" =~ ^([a-zA-Z0-9._-]+){1,}$ ]]; do
    read -rp "[Enter output_directory]: " -e -i 'build_22.04-example' src_path
  done
fi

if [[ "$dest_path" == '' ]]; then
  echo "[*]Set a destination path for the VM files. Default is '/var/lib/libvirt'"
  echo ""
  until [[ "$dest_path" =~ ^(/[a-zA-Z0-9._-]+){1,}$ ]]; do
    read -rp "[Enter full path without the trailing '/']: " -e -i '/var/lib/libvirt' dest_path
  done
fi

if virsh list --all | grep -Pq "$vm_name"; then
  echo "[*]WARNING: a virtual machine matching \"$vm_name\" already exists. Exiting..."
  exit 1
fi

if ! [ -d ./"${src_path}" ]; then
  echo "[*]Change to directory containing ${src_path} before executing."
  exit
fi

# Create the destination paths if they're not the default
echo "[*]Ensuring ${dest_path} exists..."
sudo mkdir -p "${dest_path}"/images
sudo mkdir -p "${dest_path}"/qemu/nvram
# Ensure libvirt has ownership and ACL permissions over the image path
#sudo chown -R libvirt-qemu:kvm "${dest_path}"
#sudo setfacl -R -m u:libvirt-qemu:rx "${dest_path}"

# Move the VM disk image and EFI variables into the correct virt-manager paths.
# The build image file name should always be "ubuntu-2204-desktop", we change this when it's imported into virt-manager using $vm_name here
echo "[*]Copying VM files to virt-manager path..."
sudo cp "${src_path}"/efivars.fd "${dest_path}"/qemu/nvram/"${vm_name}"_VARS.fd
sudo cp "${src_path}"/*.qcow2 "${dest_path}"/images/"${vm_name}".qcow2

# Set the ownership to `libvirt-qemu:kvm` (this was done on an Ubuntu host, your user:group may be different).
echo "[*]Changing ownership to libvirt-qemu:kvm..."
sudo chown libvirt-qemu:kvm "${dest_path}"/images/"${vm_name}".qcow2
sudo chown libvirt-qemu:kvm "${dest_path}"/qemu/nvram/"${vm_name}"_VARS.fd

# Without `--autoconsole none`` this will connect a GUI display to the VM
echo "[*]Running virt-install..."
virt-install \
  --autoconsole none \
  --name "${vm_name}" \
  --os-variant "${vm_os}" \
  --vcpus "${vm_vcpus}" \
  --memory "${vm_memory}" \
  --machine q35 \
  --disk path="${dest_path}"/images/"${vm_name}".qcow2,format=qcow2,bus=virtio \
  --import \
  --features smm.state=on \
  --boot loader=/usr/share/OVMF/OVMF_CODE_4M.secboot.fd,loader.readonly=yes,loader_secure=yes,loader.type=pflash,nvram.template=/usr/share/OVMF/OVMF_VARS_4M.ms.fd,nvram="${dest_path}"/qemu/nvram/"${vm_name}"_VARS.fd \
  --tpm default \
  --rng /dev/urandom \
  --network network="${vm_net}",model=virtio \
  --video qxl \
  --channel spicevmc

echo "[*]VM imported and booting, waiting to shutdown..."
while (virsh list --all | grep "${vm_name}" | grep running >/dev/null); do
  virsh shutdown "${vm_name}"
  sleep 30
done

# https://wiki.libvirt.org/Determining_version_information_dealing_with_unknown_procedure.html
if virsh -v | grep -Pqx "(\d){2}(\.\d+){2,}"; then
  echo "[*]Taking snapshot..."
  if virsh snapshot-create-as "${vm_name}" base_install --description "Imported from packer."; then
    echo "[*]Import completed successfully. Refresh the snapshot list in the GUI."
  else
    echo "[*]Error, quitting..."
    exit 1
  fi
else
  echo "[*]Internal snapshots on VM's with NVRAM require libvirtd version 10.0.0 or higher (Ubuntu 24.04)"
  echo "   See: https://github.com/virt-manager/virt-manager/issues/851"
fi
