# kali-2025.2-headless.pkrvarc.hcl

disk_file        = "kali-linux"
vm_hostname      = "kali"
iso_url          = "https://cdimage.kali.org/kali-2025.2/kali-linux-2025.2-installer-amd64.iso"
iso_checksum     = "5723d46414b45575aa8e199740bbfde49e5b2501715ea999f0573e94d61e39d3"
iso_storage_path = "/home/user/iso/kali-linux-2025.2-installer-amd64.iso"
preseed_file     = "preseed-headless.cfg"
preseed_checksum = "b0a886d0ad85918c0ced0fe7f4dab3ac"
output_directory = "build_kali-linux_headless"

playbook_file = "./ansible/kali-headless.yml"

extra_arguments = [
  "--extra-vars",
  "@./ansible/vault.example.txt",
  "--vault-password-file=./ansible/pwfile"
]

inline = [
  "echo 'packer' | sudo -S apt update",
  "echo 'packer' | sudo -S DEBIAN_FRONTEND=noninteractive apt full-upgrade -y -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold'",
]
