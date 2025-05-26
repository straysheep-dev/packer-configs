# 22.04-desktop.pkrvars.hcl

disk_file = "ubuntu-2204.qcow2"

iso_storage_path = "/home/user/iso/ubuntu-22.04.4-live-server-amd64.iso"

output_directory = "build_22.04-desktop"

playbook_file = "../ansible/ubuntu-22.04-desktop.yml"

extra_arguments = [
  "--extra-vars",
  "@../ansible/vault.txt",
  "--vault-password-file=../ansible/pwfile"
]

inline = [
  "sudo sed -i /etc/default/grub -e 's/GRUB_CMDLINE_LINUX_DEFAULT=\".*/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash\"/'",
  "sudo update-grub",
  "sudo apt update",
  "sudo DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a apt full-upgrade -y",
]
