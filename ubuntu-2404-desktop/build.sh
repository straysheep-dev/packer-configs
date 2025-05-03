#!/bin/bash

# Set this to a path for local ISO storage, if you have none the ISO will be downloaded
if [[ "$iso_path" == '' ]]; then
    echo "[*]Set an optional path to local ISO files with: $ export iso_path='/path/to/ubuntu.iso'"
    exit 1
fi

if ! [[ -e ./seed.img ]]; then
    echo "[*]No seed.img file found. Please build the seed ISO first with: $ bash ./create-data-iso.sh"
    exit 1
fi

# Build the VM
packer build \
    -var "iso_storage_path=file://${iso_path}" .
