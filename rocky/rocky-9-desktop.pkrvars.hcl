# rocky-9-desktop.pkrvars.hcl

vm_name = "rocky-9"

iso_url      = "https://download.rockylinux.org/pub/rocky/9/isos/x86_64/Rocky-9.7-x86_64-dvd.iso"
iso_checksum = "d48e902325dce6793935b4e13672a0d9a4f958e02d4e23fcf0a8a34c49ef03da"

iso_storage_path = "/home/user/iso/Rocky-9.7-x86_64-dvd.iso"

output_directory = "build_rocky-9-desktop"

ks_file = "ks-desktop.cfg"

playbook_file = "./ansible/rocky-9-desktop.yml"

extra_arguments = [
  "--extra-vars",
  "@./ansible/vault.example.txt",
  "--vault-password-file=./ansible/pwfile"
]

inline = [
  "echo 'packer' | sudo -S dnf update -y",
]