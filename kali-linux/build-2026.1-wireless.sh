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
        -var "iso_storage_path=${HOME}/iso/kali-linux-2026.1-installer-netinst-amd64.iso" \
        -var "iso_checksum=caf5ff7d7a4f73c85a6f1688300b936d3d7fd6965c52d80632e36709a09255a7" \
        -var-file kali-2026.1-wireless.pkrvars.hcl \
        -only="kali-linux.qemu.kali-linux" \
        .
done
