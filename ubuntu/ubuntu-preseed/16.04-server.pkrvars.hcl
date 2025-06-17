# 16.04-server.pkrvars.hcl

vm_name = "ubuntu-1604"

iso_url      = "https://releases.ubuntu.com/16.04/ubuntu-16.04.7-server-amd64.iso"
iso_checksum = "b23488689e16cad7a269eb2d3a3bf725d3457ee6b0868e00c8762d3816e25848"

iso_storage_path = "/home/user/iso/ubuntu-16.04.7-server-amd64.iso"

output_directory = "build_16.04-server"

inline = [
  "echo 'packer' | sudo -S apt update",
  "echo 'packer' | sudo -S DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a apt full-upgrade -y",
]
