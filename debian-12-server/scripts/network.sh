#!/bin/bash

# https://www.vagrantup.com/docs/boxes/base.html
# https://gitlab.com/kalilinux/build-scripts/kali-vagrant/-/blob/master/scripts/vagrant.sh?ref_type=heads

# This attempts to ensure dhcp and networking gets automatically configured,
# no matter how you chose to name the network interfaces.

echo '
auto eth0
allow-hotplug eth0
iface eth0 inet dhcp' | tee -a /etc/network/interfaces

echo '
auto enp0s2
allow-hotplug enp0s2
iface enp0s2 inet dhcp' | tee -a /etc/network/interfaces
