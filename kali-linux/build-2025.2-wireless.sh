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
        -var "iso_storage_path=${HOME}/iso/kali-linux-2025.2-installer-amd64.iso" \
        -var "iso_checksum=5723d46414b45575aa8e199740bbfde49e5b2501715ea999f0573e94d61e39d3" \
        -var-file kali-2025.2-wireless.pkrvars.hcl \
        -only="kali-linux.qemu.kali-linux" \
        .
done
