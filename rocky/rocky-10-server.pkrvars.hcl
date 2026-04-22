# rocky-10-server.pkrvars.hcl

vm_name = "rocky-10"

iso_url      = "https://download.rockylinux.org/pub/rocky/9/isos/x86_64/Rocky-10.1-x86_64-dvd1.iso"
iso_checksum = "55f96d45a052c0ed4f06309480155cb66281a008691eb7f3f359957205b1849a"

iso_storage_path = "/home/user/iso/Rocky-10.1-x86_64-dvd1.iso"

output_directory = "build_rocky-10-server"

ks_file = "ks-server.cfg"

playbook_file = "./ansible/rocky-10-server.yml"

extra_arguments = [
  "--extra-vars",
  "@./ansible/vault.example.txt",
  "--vault-password-file=./ansible/pwfile"
]

inline = [
  "echo 'packer' | sudo -S dnf update -y",
]