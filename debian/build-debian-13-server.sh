#!/bin/bash

# shellcheck disable=SC2034

# Build the VM
# Change to PACKER_LOG=1 for debug output
PACKER_LOG=0 \

actions='validate build'

for action in $actions
do
    packer "$action" \
        -var "iso_storage_path=${HOME}/iso/debian-13.3.0-amd64-netinst.iso" \
        -var "cpus=4" \
        -var "memory=4096" \
        -var-file="debian-13-server.pkrvars.hcl" \
        .
done
