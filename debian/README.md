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


## Building the Image

```bash
# Initialize packer
packer init .

VM_HOSTNAME="debian12-$(cat /proc/sys/kernel/random/uuid | cut -d '-' -f1)"

# Run the build process for QEMU
packer build \
    -var vm_hostname="${VM_HOSTNAME}" \
    -only="debian12.qemu.debian12" \
    debian.pkr.hcl
```

You can also change any `-var` arguments as needed in the build script, then execute it.

```bash
bash ./build.sh
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

During the build process, packer may use a different network interface name than the one you find after booting the resulting build. In this case, `ens4` was used during the build, and `enp0s2` was the name of the interface when booting with `kvm` after the build.

You will need to update [`/etc/network/interfaces` to point to the correct interface name](https://wiki.debian.org/NetworkConfiguration#Network_Interface_Names), otherwise DHCP will fail on first *manual* boot. This still needs resolved through the build process.

Replace `ethX` with the actual interface name to make this fix more permanent:

```conf
auto ethX
allow-hotplug ethX
iface ethX inet dhcp
```

In the meantime, you can get around this and obtain an IP address manually after booting with:

```bash
sudo dhclient -v
```
