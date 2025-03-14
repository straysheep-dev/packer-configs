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
  default = "kali-linux"
}

variable "vm_hostname"  {
  type    = string
  default = "kali"
}

variable "iso_urls" {
    type    = list(string)
    default = [
    "file:///home/user/iso/kali-linux-2025.1a-installer-amd64.iso",
    "https://cdimage.kali.org/kali-2025.1a/kali-linux-2025.1a-installer-amd64.iso"
  ]
}

variable "iso_checksum" {
    type    = string
    default = "5c3e195d8e8c5857d75e5c82df861852de0063c54f9cd9f9cba6e29be53367fb"
}

variable "iso_storage_path" {
    type    = string
    default = "/home/user/iso/"
}

source "qemu" "kali-linux" {
  accelerator        = "kvm"
  boot_command       = [
    "e<wait>",
    "<down><down><down><end>",
    " --- ",
    "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
    "preseed/url/checksum=c90fd407f89b72924c15a2f50bcec0b3 ",
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
  ssh_username       = "kali"
  vm_name            = "${var.vm_name}"
}

build {
  name    = "${var.vm_name}"
  sources = ["source.qemu.kali-linux"]

  provisioner "shell" {
      inline = ["echo 'packer' | sudo -S apt update; sudo -S apt full-upgrade -y"]
  }

  provisioner "ansible" {
    extra_arguments = ["--extra-vars", "ansible_become_password=packer"]
    playbook_file   = "./ansible/playbook.yml"
  }

}
