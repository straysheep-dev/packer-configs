# packer-configs

![packer workflow](https://github.com/straysheep-dev/packer-configs/actions/workflows/packer.yml/badge.svg) ![ansible-lint workflow](https://github.com/straysheep-dev/ansible-configs/actions/workflows/ansible-lint.yml/badge.svg) ![shellcheck workflow](https://github.com/straysheep-dev/packer-configs/actions/workflows/shellcheck.yml/badge.svg)

A collection of Packer templates for various uses. These were written in a way that should help you understand `packer` by looking at how they work, and expanding on them.

> [!NOTE]
> The status for ansible-lint is from the [straysheep-dev/ansible-configs](https://github.com/straysheep-dev/ansible-configs) repo. These roles will always be sync'd from there, unmodified. The CI workflow here appears to have issues even with the `working_directory:` argument.

## Resources

A list of resources used to create these templates.

- [Packer QEMU Builder](https://developer.hashicorp.com/packer/integrations/hashicorp/qemu/latest/components/builder/qemu#basic-example)
- [Packer QEMU Plugin UEFI Boot](https://github.com/hashicorp/packer-plugin-qemu/issues/97)
- [Cloud-init Autoinstall Reference](https://canonical-subiquity.readthedocs-hosted.com/en/latest/reference/autoinstall-reference.html#user-data)
- [Cloud-init user-data Reference](https://docs.cloud-init.io/en/latest/reference/examples.html)
- [Cloud-init ISO Disk vs HTTP Server](https://cloudinit.readthedocs.io/en/latest/howto/launch_qemu.html#create-an-iso-disk)
- [Debian Secure Boot VM Settings](https://wiki.debian.org/SecureBoot/VirtualMachine)
- [Ubuntu Server UEFI-Enabled Templates](https://github.com/shantanoo-desai/packer-ubuntu-server-uefi/blob/main/templates/ubuntu.pkr.hcl)
- [chef/bento Packer Templates](https://github.com/chef/bento/blob/6fe9fa20d1f37e916a7babdee87c89ba38ce54a4/packer_templates/pkr-builder.pkr.hcl)
- [Packer Guides: Unattended Installs](https://developer.hashicorp.com/packer/guides/automatic-operating-system-installs/preseed_ubuntu)
- [github.com/canonical/autoinstall-desktop](https://github.com/canonical/autoinstall-desktop)
- [github.com/canonical/packer-maas Templates](https://github.com/canonical/packer-maas/blob/main/ubuntu/ubuntu-lvm.pkr.hcl)
- [`boot_command` Examples](https://developer.hashicorp.com/packer/docs/community-tools#templates)
- [kali-vagrant Build Scripts](https://gitlab.com/kalilinux/build-scripts/kali-vagrant)
- [Ubuntu Docs: Virtual Machine Manager](https://documentation.ubuntu.com/server/how-to/virtualisation/virtual-machine-manager/index.html)
- [Support added for internal snapshots of UEFI VM's in virt-manager](https://github.com/virt-manager/virt-manager/issues/851)


## Getting Started

**ISO and IMG File Management**

- Packer will write ISO's to `~/.cache/packer/`
- You can move these to a more standard path like `~/iso` or `~/src/my-project/ubuntu-2204/iso/`
- This means you can even tell packer to save ISOs it fetches to that path instead of cache
- You can also tell packer to try a local file first before fetching the remote file
- If you intend to use virt-manager, the path for those files is `/var/lib/libvirt/`

**Using Packer**

- Use `packer` only for what's necessary
- Ideally all you use Packer for is the base install and deployment of a machine
- Handle complex configuration and tasks with tools like Ansible, externally or via the plugin after the build completes
- This reduces issues Packer can run into, and makes your templates more portable


## Essential Commands

Manually install plugins.

```bash
# List installed plugins
packer plugins installed

# Install plugins
packer plugins install github.com/hashicorp/ansible
packer plugins install github.com/hashicorp/qemu
```

Initialize a packer template. This downloads any missing plugins described in the `packer {}` block to your local machine. **Review plugins before executing this**.

```bash
cd /path/to/my-packer-project
packer init .
```

Format the packer templates. Rewrites HCL2 config files to canonical format. *Run this after making edits to your templates or as part of CI/CD*.

```bash
packer fmt .
```

Validate the packer templates. *Run this after making edits to your templates or as part of CI/CD*.

```bash
packer validate .
```

Start a build. This will launch whatever is necessary to build the template, and may take some time. In a GUI you'll see the machine launch and build live.

```bash
packer build .
```


## Boot Commands

This is possibly the most esoteric piece of packer if you're just getting started and haven't read how to write these yourself. Packer automates building VMs. This sometimes includes the literal key presses it takes as if you were building one manually. Packer emulates these key presses so the entire process is fully automated. [Packer's boot command syntax](https://developer.hashicorp.com/packer/integrations/hashicorp/qemu/latest/components/builder/qemu#boot-configuration) is summarized in the link as:

> The boot command "typed" character for character over a VNC connection to the machine, simulating a human actually typing the keyboard.

Use that guide to help you write and modify your own boot commands.


## Packer and Ansible

Ansible often requires a credential, whether it's to a vault or for sudo to execute elevated tasks. There are two easy ways to do this in a more secure way than hard-coding a plaintext passphrase.

1. A "password file" containing the user's `sudo` password in raw text, on one line. Point to this file with `--become-password-file=./ansible/pwfile`.


```hcl
build {
  name    = "my-vm"
  sources = ["source.qemu.my-vm"]

  provisioner "ansible" {
    playbook_file = "./ansible/playbook.yml"
    extra_arguments = [
      "--become-password-file=./ansible/pwfile"
    ]
  }
}
```

2. A "password file" containing a the password to an Ansible vault. Do the same as above, pointing to a file containing just this string, on one line.

```hcl
build {
  name    = "my-vm"
  sources = ["source.qemu.my-vm"]

  provisioner "ansible" {
    playbook_file = "./ansible/playbook.yml"
    extra_arguments = [
      "--extra-vars",
      "@./ansible/vault.txt",
      "--vault-password-file=./ansible/pwfile"
    ]
  }
}
```

*As better ways to handle credentials are tested across platforms, and with CI/CD, they will be added here.*


## Ansible hostfwd

You can use the `-netdev user,id=net0,hostfwd=tcp::2222-:22 \` port forward to reach the VM through the host to run additional Ansible roles after the build completes.

Here's an example inventory file using the host 2222:22 port forward:

```yml
packergroup:
    127.0.0.1:
        ansible_port: 2222
        ansible_user: kali
```

You'll need a public key on the packer machine, or `sudo apt install -y sshpass` on the Ansible / Packer host.


## Run Completed Builds with QEMU

Modern Linux distros support EFI boot as well as the option to run with Secure Boot functionality if you enable it. Windows 11 requires Secure Boot by default, and for some built-in threat mitigation features to work.

These resources cover what you need to execute `kvm` or `qemu-system-<arch>` to run a machine that will be installed or was installed with Secure Boot.

- [superuser/qemu-kvm-uefi-secure-boot-doesnt-work](https://superuser.com/questions/1703377/qemu-kvm-uefi-secure-boot-doesnt-work)
- [Debian Secure Boot VM Settings](https://wiki.debian.org/Secure%20Boot/VirtualMachine)

Practically what you need are 3 items: the Q35 chipset, the EFI firmware ROM (read-only) and the EFI variables unique to that machine (writable). The EFI variables file is typically copied to a place for use with that VM from `/usr/share/OVMF/OVMF_VARS_*`. Which file you need depends on which EFI ROM you used to provision the VM.

- `-machine q35,smm=on,accel...` handles the chipset, enables smm for Secure Boot, and tells the host what acceleration to prefer based on what's available, in that order
- `-drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE_4M.secboot.fd` points to the EFI ROM
- `-drive if=pflash,format=raw,file=efivars.fd` points to a local, writable, copy of the EFI variables.

This all assumes you `cd` into a `build/` directory that contains the `.qcow2` VM image, and the `efivars.fd` file that machine can write to. Boot that machine with the following command:

```bash
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


## Run Completed Builds with virt-manager

Move the VM disk image and EFI variables into the correct virt-manager paths.

```bash
sudo cp build/ubuntu-2204-desktop /var/lib/libvirt/images/ubuntu-2204-desktop.qcow2
sudo cp build/efivars.fd /var/lib/libvirt/qemu/nvram/ubuntu-2204-desktop_VARS.fd
```

Set the ownership to `libvirt-qemu:kvm` (this was done on an Ubuntu host, your user:group may be different).

```bash
sudo chown libvirt-qemu:kvm /var/lib/libvirt/images/ubuntu-2204-desktop.qcow2
sudo chown libvirt-qemu:kvm /var/lib/libvirt/qemu/nvram/ubuntu-2204-desktop_VARS.fd
```

Now open the virt-manager GUI.

- Set `Q35` for the CPU chipset
- Select UEFI firmware and choose the `OVMF_CODE_4M.secboot.fd` ROM

You will need to manually edit the `<os>` element of the XML config under CPU (or Overview).

The `<nvram>` line is what you'll need to add. Change the NVRAM path to point to the variables file you just copied over.

```xml
  <os>
    <type arch="x86_64" machine="q35">hvm</type>
    <loader readonly="yes" secure="yes" type="pflash">/usr/share/OVMF/OVMF_CODE_4M.secboot.fd</loader>
    <nvram template="/usr/share/OVMF/OVMF_VARS_4M.ms.fd">/var/lib/libvirt/qemu/nvram/ubuntu-2204-desktop_VARS.fd</nvram>
    <boot dev="hd"/>
  </os>
```

Apply, then choose "Begin installation". This will boot the VM. You will likely have a blank window after the initial QEMU boot splash screen. The easiest thing to do here is click into the blank window and press the `esc` key to cycle through the console output until you get the GUI. You can also try to close / reopen the VM window. If this doesn't fix the video output, shutdown the VM with the CLI or virt-manager tools and then close / reopen the window. You should have video output at this point.

Another issue you may encounter is when you install a desktop image onto a server VM, the networking configuration may need revised to work automatically as expected. This happened in the case of the first config in this repo, [ubuntu-2204-desktop](./ubuntu-2204-desktop/).


### Automate with virt-install

Inside each packer template folder is an `import-to-virt-manager.sh` file that will automate the steps above for you.

- [RedHat: Creating Guest VMs with `virt-install`](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/7/html/virtualization_deployment_and_administration_guide/sect-guest_virtual_machine_installation_overview-creating_guests_with_virt_install)
- [RedHat: Comparison of virt-manager and virt-install Options](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/7/html/virtualization_deployment_and_administration_guide/sect-virtual_machine_installation-virt-install-virt-manager-matrix)