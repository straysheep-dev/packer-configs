#!/bin/bash

# shellcheck disable=SC2034

# Build the VM
# Change to PACKER_LOG=1 for debug output
PACKER_LOG=0 \

actions='validate build'

for action in $actions
do
    packer "$action" \
    -var "iso_storage_path=${HOME}/iso/Rocky-9.7-x86_64-dvd.iso" \
    -var-file="rocky-9-server.pkrvars.hcl" \
    .
done