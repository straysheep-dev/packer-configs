#!/bin/bash

# Change the hostname if necessary
VM_HOSTNAME="kali-$(cat /proc/sys/kernel/random/uuid | cut -d '-' -f1)"

# Change the iso_urls paths and iso_checksum as needed

packer build \
    -var vm_hostname="${VM_HOSTNAME}" \
    -only="kali-linux.qemu.kali-linux" \
    kali-linux.pkr.hcl
