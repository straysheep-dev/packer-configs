# debian-13-server.pkrvars.hcl

vm_name = "trixie"

iso_url      = "https://cdimage.debian.org/mirror/cdimage/archive/13.3.0/amd64/iso-cd/debian-13.3.0-amd64-netinst.iso"
iso_checksum = "c9f09d24b7e834e6834f2ffa565b33d6f1f540d04bd25c79ad9953bc79a8ac02"

iso_storage_path = "/home/user/iso/debian-13.3.0-amd64-netinst.iso"

output_directory = "build_debian-13-server"

playbook_file = "./ansible/debian-13-server.yml"

extra_arguments = [
  "--extra-vars",
  "@./ansible/vault.example.txt",
  "--vault-password-file=./ansible/pwfile"
]

# Inline shell commands
inline = [
  "echo 'packer' | sudo -S apt update",
  "echo 'packer' | sudo -S DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a apt full-upgrade -y",
]

# Inline scripts to execute
execute_command = "echo 'packer' | {{.Vars}} sudo -S bash -euxo pipefail '{{.Path}}'"
scripts = [
  "./scripts/network.sh"
]
