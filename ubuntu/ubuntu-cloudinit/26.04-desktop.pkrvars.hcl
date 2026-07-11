# 26.04-desktop.pkrvars.hcl

vm_name = "ubuntu-2604"

iso_url      = "https://releases.ubuntu.com/26.04/ubuntu-26.04-live-server-amd64.iso"
iso_checksum = "dec49008a71f6098d0bcfc822021f4d042d5f2db279e4d75bdd981304f1ca5d9"

iso_storage_path = "/home/user/iso/ubuntu-26.04-live-server-amd64.iso"

output_directory = "build_26.04-desktop"

playbook_file = "../ansible/ubuntu-26.04-desktop.yml"

extra_arguments = [
  "--extra-vars",
  "@../ansible/vault.example.txt",
  "--vault-password-file=../ansible/pwfile"
]

inline = [
  "echo 'packer' | sudo -S sed -i /etc/default/grub -e 's/GRUB_CMDLINE_LINUX_DEFAULT=\".*/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash\"/'",
  "echo 'packer' | sudo -S update-grub",
  "echo 'packer' | sudo -S apt update",
  "echo 'packer' | sudo -S DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a apt full-upgrade -y -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold'",
]
