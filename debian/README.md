# debian

A packer template for building a Debian system with UEFI boot.

Supported build inventory:

- [Debian 12 Server (Bookworm)](https://cdimage.debian.org/mirror/cdimage/archive/12.10.0/amd64/iso-cd/)

Resources used to work on these templates:

- [gitlab.com/kalilinux/build-scripts](https://gitlab.com/kalilinux/build-scripts/kali-vagrant)
- [debian.org/DebianInstaller/Preseed](https://wiki.debian.org/DebianInstaller/Preseed)
- [debian.org example-preseed.txt Template](https://www.debian.org/releases/stable/example-preseed.txt)
- [debian.org/tasksel](https://wiki.debian.org/tasksel)
- [debian.org/NetworkConfiguration](https://wiki.debian.org/NetworkConfiguration#Network_Interface_Names)
- [hashicorp/packer/provisioners/shell: Quoting Environment Variables](https://developer.hashicorp.com/packer/docs/provisioners/shell#quoting-environment-variables)
- [gitlab.com/kalilinux/build-scripts Fixing Networking](https://gitlab.com/kalilinux/build-scripts/kali-vagrant/-/blob/master/scripts/vagrant.sh?ref_type=heads#L19)

> [!NOTE]
> This template is essentially a port of the [kali-linux template](../kali-linux), using the [debian.org example-preseed.txt Template](https://www.debian.org/releases/stable/example-preseed.txt), and is available under the same Apache v2.0 license.


## Building an Image

```bash
# Initialize packer
packer init .

PACKER_LOG=0 \

actions='validate build'

for action in $actions
do
    packer "$action" \
        -var "iso_storage_path=${HOME}/iso/debian-12.8.0-amd64-netinst.iso" \
        -var-file="bookworm-server.pkrvars.hcl" \
        .
done
```

You can change any `-var` arguments as needed in the build script, then execute it.

```bash
bash ./build-debian-12-server.sh
```


## Booting Debian

Use the default EFI firmware (OVMF_CODE.fd) when booting manually with QMEU when Secure Boot *isn't* in use:

```bash
cd build/ && \
kvm -no-reboot -m 4096 -smp 4 \
    -machine q35 \
    -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE_4M.fd \
    -drive if=pflash,format=raw,file=efivars.fd \
    -device virtio-net-pci,netdev=net0 \
    -netdev user,id=net0,hostfwd=tcp::2222-:22,hostfwd=tcp::8080-:80,hostfwd=tcp::8443-:443 \
    -drive file=debian12,format=qcow2,if=virtio \
    -vga virtio \
    -display gtk
```


## Troubleshooting

This is due to [predictable interface names](https://wiki.debian.org/NetworkInterfaceNames#THE_.22PREDICTABLE_NAMES.22_SCHEME), which for now are left active on these builds. It causes trouble in the case of packer or vagrant because the characteristics of the interface are likely to be different from those your builder uses to the one you assign when importing the resulting machine image into a hypervisor. This is why you'll see vagrant boxes use `eth0`.

See the [network script examples under chef/bento](https://github.com/chef/bento/tree/main/packer_templates/scripts) if you'd like to revert to the [classic interface naming convention](https://wiki.debian.org/NetworkInterfaceNames#THE_ORIGINAL_SIMPLE_SCHEME).

In one case with this template, `ens4` was used during the build, and `enp0s2` was the name of the interface when booting with `kvm` after the build.

To resolve this, you will need to update [`/etc/network/interfaces` to point to the correct interface name](https://wiki.debian.org/NetworkConfiguration#Network_Interface_Names), otherwise DHCP will fail on first *manual* boot. This is still being attempted to be resolved through the build process if possible, to maintain the new interface naming schemes without the need for manual adjustments after the first boot.

In `/etc/network/interfaces`, replace `ethX` with the actual interface name to make this fix more permanent:

```conf
auto ethX
allow-hotplug ethX
iface ethX inet dhcp
```

You can obtain an IP address immediately after booting, before you make these more permenant networking changes, with:

```bash
sudo dhclient -v
```
