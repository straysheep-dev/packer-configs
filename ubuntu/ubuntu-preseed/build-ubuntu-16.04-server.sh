#!/bin/bash

# shellcheck disable=SC2034

# Build the VM
# Change to PACKER_LOG=1 for debug output
PACKER_LOG=0 \

actions='validate build'

for action in $actions
do
    packer "$action" \
        -var "iso_storage_path=${HOME}/iso/ubuntu-16.04.7-server-amd64.iso" \
        -var-file="16.04-server.pkrvars.hcl" \
        .
done
