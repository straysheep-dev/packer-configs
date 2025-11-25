# kali-2025.1c-wireless.pkrvarc.hcl

disk_file        = "kali-linux"
vm_hostname      = "kali"
iso_url          = "https://cdimage.kali.org/kali-2025.2/kali-linux-2025.2-installer-amd64.iso"
iso_checksum     = "5723d46414b45575aa8e199740bbfde49e5b2501715ea999f0573e94d61e39d3"
iso_storage_path = "/home/user/iso/kali-linux-2025.2-installer-amd64.iso"
preseed_file     = "preseed-desktop-xfce.cfg"
preseed_checksum = "44aac3a666e502d9ec39fecf14d98e73"
output_directory = "build_kali-linux_wireless"

playbook_file = "./ansible/kali-wireless.yml"

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
