# 20.04-server.pkrvars.hcl

vm_name = "ubuntu-2004"

iso_url      = "https://releases.ubuntu.com/20.04/ubuntu-20.04.6-live-server-amd64.iso"
iso_checksum = "b8f31413336b9393ad5d8ef0282717b2ab19f007df2e9ed5196c13d8f9153c8b"

iso_storage_path = "/home/user/iso/ubuntu-20.04.6-live-server-amd64.iso"

output_directory = "build_20.04-server"

playbook_file = "../ansible/ubuntu-20.04-server.yml"

extra_arguments = [
  "--extra-vars",
  "@../ansible/vault.example.txt",
  "--vault-password-file=../ansible/pwfile"
]

inline = [
  "echo 'packer' | sudo -S apt update",
  "echo 'packer' | sudo -S DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a apt full-upgrade -y",
]
