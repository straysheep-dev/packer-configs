#!/bin/bash

# Change the hostname if necessary
VM_HOSTNAME="debian12-$(cat /proc/sys/kernel/random/uuid | cut -d '-' -f1)"

# Change the iso_urls paths and iso_checksum as needed

packer build \
    -var vm_hostname="${VM_HOSTNAME}" \
    -only="debian12.qemu.debian12" \
    debian.pkr.hcl
