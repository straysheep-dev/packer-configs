#!/bin/bash

# This script will mount the virito-win.iso, and find all drivers related to
# a specific Windows version.

# Reinitialize the variables
virtio_iso_path=''
win_version=''
vm_arch=''

echo "[*]Where is the virtio-win.iso located?"
echo ""
until [[ "${virtio_iso_path}" =~ ^(/[a-zA-Z0-9._-]+){1,}.iso$ ]]; do
    read -rp "[Enter the full path]: " -e -i ~/iso/virtio-win.iso virtio_iso_path
done

if ! [[ -f "${virtio_iso_path}" ]]; then
    echo "[ERROR]virtio-win.iso file not found under ${virtio_iso_path}. Exiting..."
    exit 1
fi

echo "[*]Which version of Windows are you building?"
echo ""
until [[ "${win_version}" =~ ^(2k12|2k12R2|2k16|2k19|2k22|2k25|2k3|2k8|2k8R2|w10|w11|w7|w8|w8.1|xp)$ ]]; do
    read -rp "[2k12|2k12R2|2k16|2k19|2k22|2k25|2k3|2k8|2k8R2|w10|w11|w7|w8|w8.1|xp]: " -e -i "2k22" win_version
done

echo "[*]What's the architecture of the VM you're building?"
echo ""
until [[ "${vm_arch}" =~ ^(ARM64|amd64|x86)$ ]]; do
    read -rp "[ARM64|amd64|x86]: " -e -i "amd64" vm_arch
done

# Mount the virtio-iso as read-only to obtain the drivers
echo "[*]Mounting ${virtio_iso_path} -> /mnt/virtio"
sudo mkdir -p /mnt/virtio || exit 1
sudo mount -o loop "${virtio_iso_path}" /mnt/virtio || exit 1

# Remove any leftover list
rm -f virtio-drivers.list 2>/dev/null
# Use regex with find to print the list
find /mnt/virtio/ -type f -regextype posix-extended -regex ".*/${win_version}/${vm_arch}/.*" -not -name "*.pdb" -print0 | xargs -0 ls | tee -a virtio-drivers.list >/dev/null
# Add double quotes to each line
sed -i -E 's/(^|$)/"/g' virtio-drivers.list
# Append a comma to each line
sed -i 's/$/,/g' virtio-drivers.list

echo ""
echo "[*]Writing driver list to virtio-drivers.list in JSON-ready format..."

# Unmount the virtio-win.iso
sudo umount /mnt/virtio
echo "[*]Unmounting /mnt/virtio."