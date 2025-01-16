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

vm_name='ubuntu-2204-desktop'
vm_os='ubuntu22.04'
vm_vcpus='4'
vm_memory='8192'
vm_net='default'

if ! [ -d ./build ]; then
  echo "[*]Change to packer template directory before executing."
  exit
fi

# Move the VM disk image and EFI variables into the correct virt-manager paths.
echo "[*]Copying VM files to virt-manager path..."
sudo cp build/"${vm_name}" /var/lib/libvirt/images/"${vm_name}".qcow2
sudo cp build/efivars.fd /var/lib/libvirt/qemu/nvram/"${vm_name}"_VARS.fd

# Set the ownership to `libvirt-qemu:kvm` (this was done on an Ubuntu host, your user:group may be different).
echo "[*]Changing ownership to libvirt-qemu:kvm..."
sudo chown libvirt-qemu:kvm /var/lib/libvirt/images/"${vm_name}".qcow2
sudo chown libvirt-qemu:kvm /var/lib/libvirt/qemu/nvram/"${vm_name}"_VARS.fd

# Without `--autoconsole none`` this will connect a GUI display to the VM
echo "[*]Running virt-install..."
virt-install \
  --autoconsole none \
  --name "${vm_name}" \
  --os-variant "${vm_os}" \
  --vcpus "${vm_vcpus}" \
  --memory "${vm_memory}" \
  --machine q35 \
  --disk path=/var/lib/libvirt/images/"${vm_name}".qcow2,format=qcow2,bus=virtio \
  --import \
  --features smm.state=on \
  --boot loader=/usr/share/OVMF/OVMF_CODE_4M.secboot.fd,loader.readonly=yes,loader_secure=yes,loader.type=pflash,nvram.template=/usr/share/OVMF/OVMF_VARS.fd,nvram=/var/lib/libvirt/qemu/nvram/"${vm_name}"_VARS.fd \
  --tpm default \
  --rng /dev/urandom \
  --network network="${vm_net}",model=virtio \
  --video qxl \
  --channel spicevmc \

echo "[*]VM imported and booting, waiting to shutdown..."
while (virsh list --all | grep "${vm_name}" | grep running >/dev/null); do
  virsh shutdown "${vm_name}"
  sleep 30
done

echo "[*]Taking snapshot..."
virsh snapshot-create-as "${vm_name} base_install --description "Imported from packer."

echo "[*]Import completed successfully. Refresh the snapshot list in the GUI."