# kali-2026.1-dev.pkrvarc.hcl

disk_file        = "kali-linux"
vm_hostname      = "kali"
iso_url          = "https://cdimage.kali.org/kali-2026.1/kali-linux-2026.1-installer-netinst-amd64.iso"
iso_checksum     = "caf5ff7d7a4f73c85a6f1688300b936d3d7fd6965c52d80632e36709a09255a7"
iso_storage_path = "/home/user/iso/kali-linux-2026.1-installer-netinst-amd64.iso"
preseed_file     = "preseed-desktop-xfce.cfg"
preseed_checksum = "44aac3a666e502d9ec39fecf14d98e73"
output_directory = "build_kali-linux_dev"

playbook_file = "./ansible/kali-dev.yml"

extra_arguments = [
  "--extra-vars",
  "@./ansible/vault.example.txt",
  "--vault-password-file=./ansible/pwfile"
]

inline = [
  "echo 'packer' | sudo -S sed -i /etc/default/grub -e 's/GRUB_CMDLINE_LINUX_DEFAULT=\".*/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash\"/'",
  "echo 'packer' | sudo -S update-grub",
  "echo 'packer' | sudo -S apt update",
  "echo 'packer' | sudo -S DEBIAN_FRONTEND=noninteractive apt full-upgrade -y -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold'",
]
