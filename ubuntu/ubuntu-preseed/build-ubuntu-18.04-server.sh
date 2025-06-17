#!/bin/bash

# Build the VM
# Change to PACKER_LOG=1 for debug output
PACKER_LOG=0 \

actions='validate build'

for action in $actions
do
    packer "$action" \
        -var "iso_storage_path=${HOME}/iso/ubuntu-18.04.6-live-server-amd64.iso" \
        -var-file="18.04-server.pkrvars.hcl" \
        .
done
