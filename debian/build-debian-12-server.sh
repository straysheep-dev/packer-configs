#!/bin/bash

# shellcheck disable=SC2034

# Build the VM
# Change to PACKER_LOG=1 for debug output
PACKER_LOG=0 \

actions='validate build'

for action in $actions
do
    packer "$action" \
        -var "iso_storage_path=${HOME}/iso/debian-12.8.0-amd64-netinst.iso" \
        -var-file="bookworm-server.pkrvars.hcl" \
        .
done
