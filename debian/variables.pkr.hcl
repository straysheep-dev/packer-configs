# variables.pkr.hcl

variable "vm_name" {
  type        = string
  description = "Name of the virtual machine. Affects disk image output files and hostname."
}
variable "iso_url" {
  type        = string
  description = "Download URL to retrieve the ISO file."
}
variable "iso_checksum" {
  type        = string
  description = "SHA256SUM of the ISO file."
}
variable "iso_storage_path" {
  type        = string
  description = "Literal path to the Ubuntu ISO image for this build."
}
variable "output_directory" {
  type        = string
  description = "This creates an output directory for the build files. Each output directory must be unique per-build."
}
variable "boot_wait" {
  type        = string
  default     = "10s"
  description = "Duration string. ex: '1h5m2s' - The time to wait after booting the virtual machine to type the boot_command."
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
variable "execute_command" {
  type = string
}
variable "scripts" {
  type = list(string)
}

locals {
  accelerator = "kvm"
  boot_command = [
    "e<wait>",
    "<down><down><down><end>",
    "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
    "locale=en_US ",
    "keymap=us ",
    "hostname=${var.vm_name} ",
    "domain='' ",
    " --- ",
    "<f10>"
  ]
  boot_wait          = "${var.boot_wait}"
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
  iso_urls = [
    "file://${var.iso_storage_path}",
    "${var.iso_url}"
  ]
  memory           = "4096"
  output_directory = "${var.output_directory}"
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
  ssh_password     = "packer"
  ssh_timeout      = "60m"
  ssh_username     = "user1"
  vm_name          = "${var.vm_name}.qcow2"

  playbook_file   = "${var.playbook_file}"
  extra_arguments = "${var.extra_arguments}"
  inline          = "${var.inline}"
  execute_command = "${var.execute_command}"
  scripts         = "${var.scripts}"
}