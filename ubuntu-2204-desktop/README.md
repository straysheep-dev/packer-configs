# ubuntu-22.04-desktop

A packer template for a standard Ubuntu 22.04 Desktop.


## References

This template was built by referencing the following resources:

- [github.com/shantanoo-desai/packer-ubuntu-server-uefi](https://github.com/shantanoo-desai/packer-ubuntu-server-uefi/blob/main/templates/ubuntu.pkr.hcl)
- [HashiCorp QEMU Builder Examples](https://developer.hashicorp.com/packer/integrations/hashicorp/qemu/latest/components/builder/qemu#basic-example)

The idea for this template was based on the work documentated under [github.com/canonical/autoinstall-desktop](https://github.com/canonical/autoinstall-desktop/blob/main/autoinstall.yaml), which is an excellent reference but is outdated. You don't need to uninstall anything (it's a preference to leave the server utilities installed on the desktop environment) and the default snaps are now installed automatically with the `ubuntu-desktop-minimal` package.

> [!TIP]
> With Packer, it's often easier to use Packer itself (and cloud-init) to simply install the VM with as few modifications as possible, and then configure it later with the various provisioners. Cloud-init in particular can be very tricky to work with when combined with Packer.


## Usage

This will build an Ubuntu 22.04 server and convert it into a full desktop environment. It does this with two files.

- `ubuntu-2204.pkr.hcl` is a "template" containing all of the packer, source, and build blocks referencing the `variables.pkr.hcl` file.
- `variables.pkr.hcl` defines all of the unique values to build the VM.

There are two files you may want to modify under `ansible/`.

- `pwfile` contains "password123", and unlocks vault.txt
- `vault.txt` is an Ansible vault that contains user1's password of "ubuntu"

Create and edit a vault ([you will need Ansible installed](https://github.com/straysheep-dev/ansible-configs?tab=readme-ov-file#setup)):

```bash
rm ./ansible/vault.txt
ansible-vault create ./ansible/vault.txt

# Edit the vault later
ansible-vault edit ./ansible/vault.txt

# Ensure your new password is written to pwfile
echo '<more-secure-password>' | tee ./ansible/pwfile
```

Ultimately these files aren't really sensitive, as you should be using Ansible or the shell provisioner to lock down the machine during the build as necessary.

This template also requires a prebuilt **seed.img** ISO file using `genisoimage` rather than serving the cloud-init config over http. To do this, from this template directory:

> [!IMPORTANT]
> Change or remove the example SSH public key string from `http/user-data`.

```bash
# https://cloudinit.readthedocs.io/en/latest/howto/launch_qemu.html#create-an-iso-disk
sudo apt update; sudo apt install -y genisoimage
genisoimage \
    -output seed.img \
    -volid cidata -rational-rock -joliet \
    http/user-data http/meta-data
```

The seed.img file is mounted as a cdrom on the VM. To avoid issues with two `-drive` directives, such as `-drive file=seed.img,index=1,media=cdrom`, this packer template uses `-cdrom` instead. cloud-init will automatically look for this data in a mounted CD image without any additional configuration. [This example](https://docs.cloud-init.io/en/latest/howto/launch_qemu.html#create-your-configuration) details how to do all of this manually for QEMU.

To run the build:

```bash
# Change the iso storage path to point to where your iso files are
packer build \
-var "iso_storage_path=file:///path/to/iso/files/" .
```

The Ansible and shell provisioners in the `build {}` block are responsible for configuration, in this case the shell block is what converts the server into a desktop.

Launch the resulting build, whether it's a desktop or server, with:

```bash
# https://superuser.com/questions/1703377/qemu-kvm-uefi-secure-boot-doesnt-work
# https://wiki.debian.org/SecureBoot/VirtualMachine

cd build/ && \
kvm -no-reboot -m 4096 -smp 4\
  -cpu host \
  -machine q35,smm=on,accel=kvm:hvf:whpx:tcg \
  -global driver=cfi.pflash01,property=secure,value=on \
  -device virtio-net-pci,netdev=net0 \
  -netdev user,id=net0,hostfwd=tcp::2222-:22 \
  -object rng-random,filename=/dev/urandom,id=rng0 \
  -drive file=ubuntu-2204,format=qcow2,if=virtio \
  -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE_4M.secboot.fd \
  -drive if=pflash,format=raw,file=efivars.fd \
  -vga virtio \
  -display gtk

```

You can also simply point to the disk file with virt-manager or any other hypervisor that can read qcow2 images. Otherwise convert the image with qemu utils and import it.