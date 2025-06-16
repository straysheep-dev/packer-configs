# 22.04-server.pkrvars.hcl

vm_name = "ubuntu-2204"

iso_url      = "https://old-releases.ubuntu.com/releases/22.04/ubuntu-22.04.4-live-server-amd64.iso"
iso_checksum = "45f873de9f8cb637345d6e66a583762730bbea30277ef7b32c9c3bd6700a32b2"

iso_storage_path = "/home/user/iso/ubuntu-22.04.4-live-server-amd64.iso"

output_directory = "build_22.04-server"

playbook_file = "../ansible/ubuntu-22.04-server.yml"

extra_arguments = [
  "--extra-vars",
  "@../ansible/vault.example.txt",
  "--vault-password-file=../ansible/pwfile"
]

inline = [
  "sudo apt update",
  "sudo DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a apt full-upgrade -y",
]
