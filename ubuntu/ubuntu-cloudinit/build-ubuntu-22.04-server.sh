#!/bin/bash

# Build the VM
# Change to PACKER_LOG=1 for debug output
PACKER_LOG=0 \
packer build \
    -var "vm_name=ubuntu-2204" \
    -var "iso_storage_path=${HOME}/iso/ubuntu-22.04.4-live-server-amd64.iso" \
    -var-file="22.04-server.pkrvars.hcl" \
    .
