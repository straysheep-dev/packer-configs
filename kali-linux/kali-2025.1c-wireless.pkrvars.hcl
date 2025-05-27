# kali-2025.1c-wireless.pkrvarc.hcl

disk_file        = "kali-linux"
vm_hostname      = "kali"
iso_url          = "https://cdimage.kali.org/kali-2025.1c/kali-linux-2025.1c-installer-amd64.iso"
iso_checksum     = "2f6e18d53a398e18e5961ed546ed1469fd3b9b40a368e19b361f4dd994e6843a"
iso_storage_path = "/home/user/iso/kali-linux-2025.1c-installer-amd64.iso"
output_directory = "build_kali-linux"

playbook_file = "./ansible/kali-linux.yml"

extra_arguments = [
  "--extra-vars",
  "@../ansible/vault.txt",
  "--vault-password-file=../ansible/pwfile",
  "-e",
  "'{\"core_tools\":true,\"wireless_tools\":true}'"
]

inline = [
  "echo 'packer' | sudo -S sed -i /etc/default/grub -e 's/GRUB_CMDLINE_LINUX_DEFAULT=\".*/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash\"/'",
  "echo 'packer' | sudo -S update-grub",
  "echo 'packer' | sudo -S apt update",
  "echo 'packer' | sudo -S DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a apt full-upgrade -y",
]
