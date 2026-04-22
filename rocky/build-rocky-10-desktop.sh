#!/bin/bash

# shellcheck disable=SC2034

# Build the VM
# Change to PACKER_LOG=1 for debug output
PACKER_LOG=0 \

actions='validate build'

for action in $actions
do
    packer "$action" \
    -var "iso_storage_path=${HOME}/iso/Rocky-10.1-x86_64-dvd1.iso" \
    -var-file="rocky-10-desktop.pkrvars.hcl" \
    .
done