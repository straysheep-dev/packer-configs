#!/bin/bash

# Modifyable variables
vm_name="win2k22"
win_iso_path="$HOME/iso/windows-server-2022.iso"
win_iso_checksum="3e4fa6d8507b554856fc9ca6079cc402df11a8b79344871669f0251535255325"

# Mount the virtio-iso as read-only to obtain the drivers
sudo mkdir -p /mnt/virtio /tmp/virtio-drivers || exit 1
sudo mount -o loop ~/iso/virtio-win.iso /mnt/virtio || exit 1

# Server 2022:
packer build \
    --only=qemu \
    -var vm_name="${vm_name}" \
    -var iso_url="${win_iso_path}" \
    -var iso_checksum="sha256:${win_iso_checksum}" \
    -var virtio_win_iso="${virtio_iso_path}" \
    ./windows-server-2022.json

# Unmount the virtio-win.iso
sudo umount /mnt/virtio
