# 22.04-server.pkrvars.hcl

disk_file = "ubuntu-2204.qcow2"

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
