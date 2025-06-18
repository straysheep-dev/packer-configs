# bookworm-server.pkrvars.hcl

vm_name = "bookworm"

iso_url      = "https://cdimage.debian.org/mirror/cdimage/archive/12.8.0/amd64/iso-cd/debian-12.8.0-amd64-netinst.iso"
iso_checksum = "04396d12b0f377958a070c38a923c227832fa3b3e18ddc013936ecf492e9fbb3"

iso_storage_path = "/home/user/iso/debian-12.8.0-amd64-netinst.iso"

output_directory = "build_bookworm-server"

playbook_file = "./ansible/bookworm-server.yml"

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
