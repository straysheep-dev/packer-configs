#!/bin/bash

# Change this
iso_path='/path/to/iso/files/'

packer build \
-var "iso_storage_path=file://${iso_path}" .