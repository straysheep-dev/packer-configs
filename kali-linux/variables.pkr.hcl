# variables.pkr.hcl

variable "disk_file" {
  type        = string
  description = "Name of the virtual machine's disk image file in the output_directory."
}

variable "vm_hostname" {
  type        = string
  description = "Set the hostname for the VM."
}

variable "iso_url" {
  type        = string
  description = "URL pointing to the ISO image for this build. This can be a local path, see build.sh for examples."
}

variable "iso_checksum" {
  type        = string
  description = "SHA256SUM of the ISO file."
}

variable "iso_storage_path" {
  type        = string
  description = "Where the ISO file is saved to disk, only if downloading is necessary. This should be modified here or via build.sh."
}

variable "output_directory" {
  type        = string
  description = "This creates an output directory for the build files. Each output directory must be unique per-build."
}

variable "playbook_file" {
  type        = string
  description = "Path to the Ansible playbook for this build. Can be a relative path."
}

variable "extra_arguments" {
  type        = list(string)
  description = "An array of arguments executed by ansible-playbook."
}

variable "inline" {
  type        = list(string)
  description = "An array of shell commands to execute during the build."
}

locals {
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
  output_directory   = "${var.output_directory}"
  shutdown_command   = "echo 'packer' | sudo -S shutdown -P now"
  ssh_password       = "packer"
  ssh_timeout        = "60m"
  ssh_username       = "kali"
  vm_name            = "${var.disk_file}"

  playbook_file   = "${var.playbook_file}"
  extra_arguments = "${var.extra_arguments}"
  inline          = "${var.inline}"
}
