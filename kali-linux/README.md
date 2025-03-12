# kali-linux

A packer template for building Kali Linux with UEFI boot.

There are three main files:

- `kali-linux.json`: The template in JSON format
- `variables.json`: The JSON template variables, these could also work with the HCL template
- `kali-linux.pkr.hcl`: A combination of both JSON files in HCL format

Kali is consistent enough in its boot parameters despite being a rolling-release distro, that this single template should work fine across a number of the recent ISOs. This is the assumption based on this template being built from the [kali-vagrant build scripts](https://gitlab.com/kalilinux/build-scripts/kali-vagrant). It seems to imply that template could work with any Kali ISO.

Resources used to work on these templates:

- [gitlab.com/kalilinux/build-scripts](https://gitlab.com/kalilinux/build-scripts/kali-vagrant)
- [debian.org/DebianInstaller/Preseed](https://wiki.debian.org/DebianInstaller/Preseed)
- [debian.org: Modifying an installation ISO image to preseed the installer](https://wiki.debian.org/DebianInstaller/Preseed/EditIso)
- [debian.org: Modifying an installation USB image to pressed the installer, for EFI boot](https://wiki.debian.org/DebianInstaller/WritableUSBStick)\
- [debian.org: Using Preseeding, Kernel Command Line Examples](https://www.debian.org/releases/bookworm/amd64/apbs02.en.html#using-preseeding)
- [Packer: Ansible Provisioner](https://developer.hashicorp.com/packer/integrations/hashicorp/ansible/latest/components/provisioner/ansible)


## UEFI Boot Commands

Translating the `boot_commands` to work with UEFI:

- The `linux` line has a built-in `preseed.cfg` specified
- Any kernel commands appended to that line appear to take precedence
- Using `---` delimits separate "sections" of the kernel commands to append more

Using `genisoimage` to create an ISO that contains the `preseed.cfg` is trickier to do on Debian.

Alternatively you can embed the `preseed.cfg` directly into the ISO (not ideal, it changes the ISO's checksum) or pass an md5sum of the `preseed.cfg` file through packer's `boot_command` list.


## Building the Image

> [!TIP]
> The build name only determines the name of the resulting qcow2 image file. This can easily be changed with a `mv` command. The variables used to determine the "name" of the VM include the *hostname*, and the *name of the VM and its qcow2 image files* when importing them into virt-manager.

It's important to run all `apt` updates through the shell provisioner before attempting to run any Ansible provisioners.The avoids `python-apt` missing as a dependancy.

As of 2025.03.08, the build will "fail" during the package install phase. Choose "continue" twice at the prompt and the autoinstall resumes without issue. It's unclear what is causing this or if it's limited to one ISO.

> [!NOTE]
> For dynamic customization, packer `variables` should be used instead of `locals`. This will let you modify values on the command line when executing the build.

Finally, in addtion to `efi_boot = true` you must specify the firmware ROM and EFI vars files to reference for the build, otherwise it will fail.

```hcl
  # These are the generic code and vars files for UEFI boot without Secure Boot
  efi_boot           = true
  efi_firmware_code  = "/usr/share/OVMF/OVMF_CODE_4M.fd"
  efi_firmware_vars  = "/usr/share/OVMF/OVMF_VARS_4M.fd"
```


### JSON Template

Building this image using the JSON template can be achieved [by following the existing kali-vagrant examples](https://gitlab.com/kalilinux/build-scripts/kali-vagrant):

```bash
# Initialize packer
packer init .

VM_HOSTNAME="kali-$(cat /proc/sys/kernel/random/uuid | cut -d '-' -f1)"

# Run the build process for QEMU
packer build \
    -var-file=variables.json \
    -var vm_hostname="${VM_HOSTNAME}" \
    -only=qemu \
    kali-linux.json
```


### HCL Template

The key differences here from the original kali-vagrant build files include:

- This build is a port of the JSON template to the HCL file format (created using `packer hcl2_upgrade kali-linux.json`)
- The firmware is set to UEFI rather than BIOS
- Swaps the Vagrant steps for Ansible role deployment for additional customization

```bash
# Initialize packer
packer init .

VM_HOSTNAME="kali-$(cat /proc/sys/kernel/random/uuid | cut -d '-' -f1)"

# Run the build process for QEMU
packer build \
    -var vm_hostname="${VM_HOSTNAME}" \
    -only="kali-linux.qemu.kali-linux" \
    kali-linux.pkr.hcl
```


## Booting Kali

Use the default EFI firmware (OVMF_CODE.fd) when booting manually with QMEU when Secure Boot *isn't* in use:

```bash
cd build/ && \
kvm -no-reboot -m 4096 -smp 4 \
    -machine q35 \
    -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE_4M.fd \
    -drive if=pflash,format=raw,file=efivars.fd \
    -device virtio-net-pci,netdev=net0 \
    -netdev user,id=net0,hostfwd=tcp::2222-:22 \
    -drive file=kali-linux,format=qcow2,if=virtio
    -vga virtio \
    -display gtk
```


## Troubleshooting

You may run into an error like this with the `qemu-guest-agent.service`:

```bash
Mar 03 22:50:14 kali systemd[1]: qemu-guest-agent.service: Bound to unit dev-virtio\x2dports-org.qemu.guest_agent.0.device, but unit isn't active.
Mar 03 22:50:14 kali systemd[1]: Dependency failed for qemu-guest-agent.service - QEMU Guest Agent.
Subject: A start job for unit qemu-guest-agent.service has failed
Defined-By: systemd

<SNIP>

A start job for unit qemu-guest-agent.service has finished with a failure.

The job identifier is 1773 and the job result is dependency.
Mar 03 22:50:14 kali systemd[1]: qemu-guest-agent.service: Job qemu-guest-agent.service/start failed with result 'dependency'.

<SNIP>

$ systemctl status dev-virtio\x2dports-org.qemu.guest_agent.0.device
 dev-virtiox2dports-org.qemu.guest_agent.0.device - /dev/virtiox2dports/org.qemu.guest_agent.0
     Loaded: loaded
     Active: inactive (dead)

$ sudo systemctl restart dev-virtio\x2dports-org.qemu.guest_agent.0.device
Failed to restart dev-virtiox2dports-org.qemu.guest_agent.0.device: Job type restart is not applicable for unit dev-virtiox2dports-org.qemu.guest_agent.0.device.
```

These resources may point you to a solution:

- [Proxmox Forum: Dependancy Failed for QEMU Guest Agent](https://forum.proxmox.com/threads/dependency-failed-for-qemu-guest-agent.75797/)
- [Red Hat: Enabling QEMU Guest Agent](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/8/html/configuring_and_managing_virtualization/enabling-qemu-guest-agent-features-on-your-virtual-machines_configuring-and-managing-virtualization)