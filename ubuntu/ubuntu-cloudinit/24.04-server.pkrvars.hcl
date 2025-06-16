# 24.04-server.pkrvars.hcl

vm_name = "ubuntu-2404"

iso_url      = "https://old-releases.ubuntu.com/releases/24.04/ubuntu-24.04.2-live-server-amd64.iso"
iso_checksum = "d6dab0c3a657988501b4bd76f1297c053df710e06e0c3aece60dead24f270b4d"

iso_storage_path = "/home/user/iso/ubuntu-24.04.2-live-server-amd64.iso"

output_directory = "build_24.04-server"

playbook_file = "../ansible/ubuntu-24.04-server.yml"

extra_arguments = [
  "--extra-vars",
  "@../ansible/vault.example.txt",
  "--vault-password-file=../ansible/pwfile"
]

inline = [
  "sudo apt update",
  "sudo DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a apt full-upgrade -y",
]
