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

variable "vm_hostname" {
  type    = string
  default = "kali"
}

variable "iso_url" {
  type        = string
  default     = "https://cdimage.kali.org/kali-2025.1c/kali-linux-2025.1c-installer-amd64.iso"
  description = "URL pointing to the ISO image for this build. This can be a local path, see build.sh for examples."
}

variable "iso_checksum" {
  type        = string
  default     = "2f6e18d53a398e18e5961ed546ed1469fd3b9b40a368e19b361f4dd994e6843a"
  description = "SHA256SUM of the ISO file."
}

variable "iso_storage_path" {
  type    = string
  default = "/home/user/iso/kali-linux-2025.1c-installer-amd64.iso"
  description = "Where the ISO file is saved to disk, only if downloading is necessary. This should be modified here or via build.sh."
}

source "qemu" "kali-linux" {
  accelerator = "kvm"
  boot_command = [
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
  iso_target_path    = "${var.iso_storage_path}"
  iso_url            = "${var.iso_url}"
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
