# kali-linux.pkr.hcl

packer {
  required_plugins {
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
  }
}

variable "vm_name" {
  type    = string
  default = "debian12"
}

variable "vm_hostname" {
  type    = string
  default = "debian12"
}

variable "iso_urls" {
  type = list(string)
  default = [
    "file:///home/user1/iso/debian-12.8.0-amd64-netinst.iso",
    "https://cdimage.debian.org/mirror/cdimage/archive/12.8.0/amd64/iso-cd/debian-12.8.0-amd64-netinst.iso"
  ]
}

variable "iso_checksum" {
  type    = string
  default = "04396d12b0f377958a070c38a923c227832fa3b3e18ddc013936ecf492e9fbb3"
}

variable "iso_storage_path" {
  type    = string
  default = "/home/user/iso/"
}

source "qemu" "debian12" {
  accelerator = "kvm"
  boot_command = [
    "e<wait>",
    "<down><down><down><end>",
    " --- ",
    "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
    "locale=en_US ",
    "keymap=us ",
    "hostname=${var.vm_hostname} ",
    "domain='' ",
    " --- ",
    "<f10>"
  ]
  cpus               = "4"
  disk_cache         = "unsafe"
  disk_compression   = true
  disk_detect_zeroes = "unmap"
  disk_discard       = "unmap"
  disk_image         = false
  disk_interface     = "virtio-scsi"
  disk_size          = "64G"
  efi_boot           = true
  efi_firmware_code  = "/usr/share/OVMF/OVMF_CODE_4M.fd"
  efi_firmware_vars  = "/usr/share/OVMF/OVMF_VARS_4M.fd"
  format             = "qcow2"
  http_directory     = "http"
  iso_checksum       = "sha256:${var.iso_checksum}"
  iso_urls           = "${var.iso_urls}"
  memory             = "4096"
  output_directory   = "build"
  shutdown_command   = "echo 'packer' | sudo -S shutdown -P now"
  ssh_password       = "packer"
  ssh_timeout        = "60m"
  ssh_username       = "user1"
  vm_name            = "${var.vm_name}"
}

build {
  name    = "${var.vm_name}"
  sources = ["source.qemu.debian12"]

  provisioner "shell" {
    inline = [
      "echo packer | sudo -S apt update",
      "echo packer | sudo -S apt full-upgrade -y"
    ]
  }
  provisioner "shell" {
    execute_command = "echo 'packer' | {{.Vars}} sudo -S bash -euxo pipefail '{{.Path}}'"
    scripts = [
      "scripts/network.sh"
    ]
  }

  provisioner "ansible" {
    extra_arguments = ["--extra-vars", "ansible_become_password=packer"]
    playbook_file   = "./ansible/playbook.yml"
  }

}
