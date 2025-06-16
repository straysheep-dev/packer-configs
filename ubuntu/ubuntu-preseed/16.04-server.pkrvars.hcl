# 16.04-server.pkrvars.hcl

vm_name = "ubuntu-1604"

iso_url      = "https://old-releases.ubuntu.com/releases/16.04.6/ubuntu-16.04.6-server-amd64.iso"
iso_checksum = "16afb1375372c57471ea5e29803a89a5a6bd1f6aabea2e5e34ac1ab7eb9786ac"

iso_storage_path = "/home/user/iso/ubuntu-16.04.6-server-amd64.iso"

output_directory = "build_16.04-server"

inline = [
  "echo 'packer' | sudo -S apt update",
  "echo 'packer' | sudo -S DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a apt full-upgrade -y",
]
