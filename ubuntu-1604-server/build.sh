#!/bin/bash

# Set this to a path for local ISO storage, if you have none the ISO will be downloaded
if [[ "$iso_path" == '' ]]; then
    echo "[*]Set an optional path to local ISO files with: $ export iso_path='/path/to/ubuntu.iso'"
    exit 1
fi

# Build the VM
packer build \
    -var "iso_storage_path=file://${iso_path}" .
