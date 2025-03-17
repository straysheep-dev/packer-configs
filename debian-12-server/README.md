# debian 12 server

A packer template for building a Debian 12 (Bookworm) server with UEFI boot.

Resources used to work on these templates:

- [gitlab.com/kalilinux/build-scripts](https://gitlab.com/kalilinux/build-scripts/kali-vagrant)
- [debian.org/DebianInstaller/Preseed](https://wiki.debian.org/DebianInstaller/Preseed)
- [debian.org example-preseed.txt Template](https://www.debian.org/releases/stable/example-preseed.txt)
- [debian.org/tasksel](https://wiki.debian.org/tasksel)
- [debian.org/NetworkConfiguration](https://wiki.debian.org/NetworkConfiguration#Network_Interface_Names)

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
    -netdev user,id=net0,hostfwd=tcp::2222-:22 \
    -drive file=debian12,format=qcow2,if=virtio \
    -vga virtio \
    -display gtk
```


## Troubleshooting

You will need to update [`/etc/network/interfaces` to point to the correct interface name](https://wiki.debian.org/NetworkConfiguration#Network_Interface_Names), otherwise DHCP will fail on first *manual* boot. This still needs resolved through the build process.

Replace `eth0` with the actual interface name:

```conf
auto eth0
allow-hotplug eth0
iface eth0 inet dhcp
```