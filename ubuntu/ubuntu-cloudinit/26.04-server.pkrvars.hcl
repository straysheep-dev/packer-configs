# 26.04-server.pkrvars.hcl

vm_name = "ubuntu-2604"

iso_url      = "https://releases.ubuntu.com/26.04/ubuntu-26.04-beta-live-server-amd64.iso"
iso_checksum = "ec11c403e5ee44952f23f21ae3db51c8df15269af68c54ec0e1d4a5991633640"

iso_storage_path = "/home/user/iso/ubuntu-26.04-beta-live-server-amd64.iso"

output_directory = "build_26.04-server"

playbook_file = "../ansible/ubuntu-26.04-server.yml"

extra_arguments = [
  "--extra-vars",
  "@../ansible/vault.example.txt",
  "--vault-password-file=../ansible/pwfile"
]

inline = [
  "echo 'packer' | sudo -S apt update",
  "echo 'packer' | sudo -S DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a apt full-upgrade -y -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold'",
]
