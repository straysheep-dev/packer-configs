# windows-server-2022

A packer template to build a "default" Windows Server 2022 machine for QEMU/KVM, on EFI firmware with guest utilies installed.

> [!NOTE]
> This template was built almost entirely from <https://github.com/StefanScherer/packer-windows> as the base, with <https://github.com/rgl/windows-vagrant> for an EFI implementation and configuration reference.

**TO DO List**

*This template is still a work-in-progress. There are a number of remaining goals left to attempt with this template.*

- Fix `import-to-virt-manager.sh` to work with Windows EFI builds
- Move from JSON to HCL2
- Support multiple server versions using dynamic arguments and scripting
- Choices for SSH, WinRM, Virtio / QEMU Guest Tools, RDP access
- Enable Secure Boot in some way, [this may be difficult](https://github.com/virtio-win/virtio-win-pkg-scripts/blob/master/README.md#virtio-win-driver-signatures)


## Licenses

This template maintains the same MIT License (MIT) as its sources.

- [StefanScherer/packer-windows/LICENSE](https://github.com/StefanScherer/packer-windows/blob/main/LICENSE)
- [rgl/windows-vagrant/LICENSE](https://github.com/rgl/windows-vagrant/blob/master/LICENSE)


## Resources

A list of resources used to create this template.

- <https://github.com/StefanScherer/packer-windows>
- <https://github.com/rgl/windows-vagrant>
- <https://schneegans.de/windows/unattend-generator/> (Credit to [rpinz](https://github.com/rpinz) for sharing this)
- <https://github.com/cschneegans/unattend-generator/>
- [Fedora: Using virtio Drivers](https://docs.fedoraproject.org/en-US/quick-docs/creating-windows-virtual-machines-using-virtio-drivers/index.html)
    - [github.com/virtio-win README: Driver Downloads and Signature Information](https://github.com/virtio-win/virtio-win-pkg-scripts/blob/master/README.md)
    - [Fedora: Windows virtio / QEMU Drivers](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/)
- [Microsoft: Create your own Answer file](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/update-windows-settings-and-scripts-create-your-own-answer-file-sxs?view=windows-11)
- [Microsoft: Unattended Windows Setup Reference](https://learn.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/)
- [Microsoft: Answer File Search Order](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/windows-setup-automation-overview?view=windows-11#implicit-answer-file-search-order)
- [PowerShell: WSMan remoting isn't supported on non-Windows platforms](https://learn.microsoft.com/en-us/powershell/scripting/security/remoting/wsman-remoting-in-powershell?view=powershell-7.4#wsman-remoting-isnt-supported-on-non-windows-platforms)
- [PowerShell: Remoting over SSH](https://learn.microsoft.com/en-us/powershell/scripting/security/remoting/ssh-remoting-in-powershell?view=powershell-7.4)
- [StefanScherer/packer-windows/issues: UEFI Builds](https://github.com/StefanScherer/packer-windows/issues/331)
- [Microsoft: Automate Windows Setup](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/automate-windows-setup?view=windows-11)
- [Microsoft: setup.exe /unattend](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/windows-setup-command-line-options?view=windows-11#unatten)
- [Microsoft: Disk Configuration XML](https://learn.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-setup-diskconfiguration-disk-modifypartitions-modifypartition-typeid#xml-example)
    - [Microsoft: How to Configure UEFI/GPT-based Disks (Manually)](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-8.1-and-8/hh824839(v=win.10))
    - [Microsoft: How to Configure UEFI/GPT-based Disks (Autounattend.xml)](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-8.1-and-8/hh825702(v=win.10))
    - [Microsoft: How to Configure BIOS/MBR-based Disks](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-8.1-and-8/hh825146(v=win.10))


## Virtio Drivers and QEMU Guest Tools

You may want to [download the virtio-win.iso](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/) file from the Fedora project to have the QEMU guest utilities installed on the VM.

> [!WARNING]
> Notice from the [github.com/virtio-win](https://github.com/virtio-win/virtio-win-pkg-scripts/blob/master/README.md#virtio-win-driver-signatures) README.
>
> Due to the [signing requirements of the Windows Driver Signing Policy](https://docs.microsoft.com/en-us/windows-hardware/drivers/install/kernel-mode-code-signing-policy\--windows-vista-and-later-#signing-requirements-by-version), drivers which are not signed by Microsoft will not be loaded by some versions of Windows when [Secure Boot](https://docs.microsoft.com/en-us/windows-hardware/design/device-experiences/oem-secure-boot) is enabled in the virtual machine. See [bug #1844726](https://bugzilla.redhat.com/1844726). The test signed drivers require enabling to load the test signed drivers. Consider [configuring the test computer to support test-signing](https://docs.microsoft.com/en-us/windows-hardware/drivers/install/configuring-the-test-computer-to-support-test-signing) and [installing `Virtio_Win_Red_Hat_CA.cer` test certificate](https://docs.microsoft.com/en-us/windows-hardware/drivers/install/installing-test-certificates) located in `/usr/share/virtio-win/drivers/by-driver/cert/` folder.

> [!NOTE]
> This template expects the virtio-win.iso utilities to be available during the build. If you don't want to use them, you'll need to modify the `autounattend.xml` file to not call them.

This example pins version "0.1.271-1" of the ISO.

```bash
virtio_iso_url='https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.271-1/virtio-win.iso'
virtio_iso_path="$HOME/iso/virtio-win.iso"
virtio_iso_checksum='bbe6166ad86a490caefad438fef8aa494926cb0a1b37fa1212925cfd81656429'

# Download the ISO, check the hash
mkdir -p ~/iso
if ! [[ -f "${virtio_iso_path}" ]]; then
    curl -Lf "${virtio_iso_url}" > "${virtio_iso_path}"
fi
sha256sum "${virtio_iso_path}" | grep "${virtio_iso_checksum}"
```


## Choosing Virtio Drivers

*This section details what the `list-virtio-drivers.sh` file does for you.*

Mount the virtio-win.iso file as read-only:

```bash
sudo mkdir -p /mnt/virtio
sudo mount -o loop ~/iso/virtio-win.iso /mnt/virtio
```

Obtain a list of all the virtio drivers you may need based on the Windows system version you're building.

```bash
# Variables to pick Windows Server version and architecture
win_version='2k22'
vm_arch='amd64'
# Remove any leftover list
rm -f virtio-drivers.list 2>/dev/null
# Use regex with find to print the list
find /mnt/virtio/ -type f -regextype posix-extended -regex ".*/$win_version/$vm_arch/.*" -not -name "*.pdb" -print0 | xargs -0 ls | tee -a virtio-drivers.list
# Add double quotes to each line
sed -i -E 's/(^|$)/"/g' virtio-drivers.list
# Append a comma to each line
sed -i 's/$/,/g' virtio-drivers.list
```

Unmount the virtio-win.iso:

```bash
sudo umount /mnt/virtio
```


## Build

*This section details what the `build.sh` file does for you.*

Make the virtio-win.iso drivers available to use with `cd_files`:

```bash
sudo mkdir -p /mnt/virtio
sudo mount -o loop ~/iso/virtio-win.iso /mnt/virtio
```

Server 2025:

```bash
packer validate ./windows-server-2025.json

packer build \
    --only=qemu \
    -var vm_name=win2k25 \
    -var iso_url=~/iso/windows-server-2025.iso \
    -var iso_checksum="sha256:d0ef4502e350e3c6c53c15b1b3020d38a5ded011bf04998e950720ac8579b23d" \
    -var virtio_win_iso=~/iso/virtio-win.iso \
    ./windows-server-2025.json
```

Server 2022:

```bash
packer build \
    --only=qemu \
    -var vm_name=win2k22 \
    -var iso_url=~/iso/windows-server-2022.iso \
    -var iso_checksum="sha256:3e4fa6d8507b554856fc9ca6079cc402df11a8b79344871669f0251535255325" \
    -var virtio_win_iso=~/iso/virtio-win.iso \
    ./windows-server-2025.json

```

Unmount the virtio-win.iso:

```bash
sudo umount /mnt/virtio
```


## Making this Template

This template is difficult to create for a number of reasons:

- The goal is to EFI boot Windows with native QEMU / Proxmox support, *and* as many security features enabled as possible
- EFI boot disallows the use of floppy disk images (these files were mounted under `a:\` in StefanScherer/packer-windows)
- `cd_files` handles the `genisoimage` steps automatically
- However, it seems there can only be 2 total disks mounted on a VM at a time without hack-y work-arounds
- This is the first problem, as you have the virtio-win.iso image, the Windows installer ISO, and now your (previously floppy) files as the third ISO
- These files must be local, and can't use an http server, because the unattend XML files rely on predictable, static, local paths
    - Not all systems will be able to use an http server either
    - You'd need to ensure the http server always binds to the same port and IP
    - You'll also need to revise all PowerShell and cmd.exe calls to scripts, so they download them first
- `"disk_interface": "sata",` doesn't seem to work without adding a SATA controller, this would need fixed after the build
- Trying to create a raw USB image file and mounting that relies on hack-y `qemu_args`
- Using `qemu_args` bypasses your JSON / HCL settings, meaning *everything* needs to be added to the `qemu_args` array
- This GitHub issue pretty much sums this up [hashicorp/packer-plugin-qemu/issues/177](https://github.com/hashicorp/packer-plugin-qemu/issues/177)
- Effectively, you'll want to use `cd_files` to handle *everything*, by extracting the virtio-win.iso files and listing them here
- Doing all of this while supporting Secure Boot and many of the Windows system protections may not be possible
