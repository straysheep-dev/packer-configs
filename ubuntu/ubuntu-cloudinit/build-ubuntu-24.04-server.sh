#!/bin/bash

# Build the VM
# Change to PACKER_LOG=1 for debug output
PACKER_LOG=0 \
packer build \
    -var "iso_storage_path=${HOME}/iso/ubuntu-24.04.2-live-server-amd64.iso" \
    -var-file="24.04-server.pkrvars.hcl" \
    .
