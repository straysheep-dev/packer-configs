# 18.04-server.pkrvars.hcl

vm_name = "ubuntu-1804"

iso_url      = "https://releases.ubuntu.com/18.04/ubuntu-18.04.6-live-server-amd64.iso"
iso_checksum = "6c647b1ab4318e8c560d5748f908e108be654bad1e165f7cf4f3c1fc43995934"

iso_storage_path = "/home/user/iso/ubuntu-18.04.6-live-server-amd64.iso"

output_directory = "build_18.04-server"

boot_wait = "4s"

inline = [
  "echo 'packer' | sudo -S apt update",
  "echo 'packer' | sudo -S DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a apt full-upgrade -y",
]
