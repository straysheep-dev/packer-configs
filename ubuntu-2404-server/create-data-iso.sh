#!/bin/bash

# https://cloudinit.readthedocs.io/en/latest/howto/launch_qemu.html#create-an-iso-disk

if ! command -v genisoimage; then
    echo "[*]Missing /usr/bin/genisoimage, prompting to install with apt..."
    sudo apt update; sudo apt install -y genisoimage
fi

if ! [ -d ./http ]; then
  echo "[*]Change to packer template directory before executing."
  exit
fi

genisoimage \
    -output seed.img \
    -volid cidata -rational-rock -joliet \
    http/user-data http/meta-data