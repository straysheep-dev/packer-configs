# 14.04-server.pkrvars.hcl

vm_name = "ubuntu-1404"

iso_url      = "https://old-releases.ubuntu.com/releases/14.04.5/ubuntu-14.04.5-server-amd64.iso"
iso_checksum = "dde07d37647a1d2d9247e33f14e91acb10445a97578384896b4e1d985f754cc1"

iso_storage_path = "/home/user/iso/ubuntu-14.04.5-server-amd64.iso"

output_directory = "build_14.04-server"

inline = [
  "echo 'packer' | sudo -S apt update",
  "echo 'packer' | sudo -S DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a apt full-upgrade -y",
]
