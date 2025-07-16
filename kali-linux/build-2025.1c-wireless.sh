#!/bin/bash

# shellcheck disable=SC2034

# Build the VM

# Change the hostname if necessary
VM_HOSTNAME="kali-$(cut -d '-' -f1 < /proc/sys/kernel/random/uuid)"

# Change to PACKER_LOG=1 for debug output

PACKER_LOG=0 \

actions='validate build'

for action in $actions
do
    packer "$action" \
        -var vm_hostname="${VM_HOSTNAME}" \
        -var "iso_url=${HOME}/iso/kali-linux-2025.1c-installer-amd64.iso" \
        -var "iso_checksum=2f6e18d53a398e18e5961ed546ed1469fd3b9b40a368e19b361f4dd994e6843a" \
        -var-file kali-2025.1c-wireless.pkrvars.hcl \
        -only="kali-linux.qemu.kali-linux" \
        .
done
