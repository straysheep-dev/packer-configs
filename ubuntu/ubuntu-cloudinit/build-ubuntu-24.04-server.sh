#!/bin/bash

# shellcheck disable=SC2034

# Build the VM
# Change to PACKER_LOG=1 for debug output
PACKER_LOG=0 \

actions='validate build'

for action in $actions
do
    packer "$action" \
    -var "iso_storage_path=${HOME}/iso/ubuntu-24.04.2-live-server-amd64.iso" \
    -var-file="24.04-server.pkrvars.hcl" \
    .
done
