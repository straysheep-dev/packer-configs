#!/bin/bash

# Build the VM
# Change to PACKER_LOG=1 for debug output

PACKER_LOG=0 \
packer build \
    -var "iso_url=${HOME}/iso/ubuntu-22.04.4-live-server-amd64.iso" \
    -var "iso_checksum=45f873de9f8cb637345d6e66a583762730bbea30277ef7b32c9c3bd6700a32b2" \
    ubuntu-2204-desktop.pkr.hcl
