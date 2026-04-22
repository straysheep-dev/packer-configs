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
  description = "Literal path to the Rocky ISO image for this build."
}
variable "output_directory" {
  type        = string
  description = "Output directory for build files. Must be unique per-build."
}
variable "boot_wait" {
  type        = string
  default     = "12s"
  description = "Time to wait after boot before sending boot_command. Rocky's GRUB menu is different than Ubuntu's."
}
variable "ks_file" {
  type        = string
  description = "Kickstart filename served from http_directory. In this case, ks-server.cfg or ks-desktop.cfg"
}
variable "playbook_file" {
  type        = string
  description = "Path to the Ansible playbook for this build."
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
  vm_name = "${var.vm_name}.qcow2"

  iso_target_path = "${var.iso_storage_path}"
  iso_checksum    = "sha256:${var.iso_checksum}"
  iso_urls = [
    "file://${var.iso_storage_path}",
    "${var.iso_url}"
  ]

  http_directory = "./http"
  http_port_min  = 3000
  http_port_max  = 3000

  output_directory = "${var.output_directory}"
  shutdown_command = "echo 'packer' | sudo -S /sbin/shutdown -P now"
  shutdown_timeout = "10m"
  headless         = false

  ssh_password = "packer"
  ssh_username = "user1"
  ssh_timeout  = "60m"

  sockets = 1
  cores   = 4
  threads = 1

  machine_type     = "q35"
  accelerator      = "kvm"
  memory           = 8192
  disk_size        = "64G"
  disk_discard     = "unmap"
  disk_compression = true
  format           = "qcow2"
  # This is necessary for RHEL based VMs that don't support the "x86-64-v2" CPU type
  qemuargs = [
    ["-cpu", "host"]
  ]

  efi_firmware_code = "/usr/share/OVMF/OVMF_CODE_4M.secboot.fd"
  efi_firmware_vars = "/usr/share/OVMF/OVMF_VARS_4M.ms.fd"
  efi_boot          = true

  vtpm            = true
  tpm_device_type = "tpm-tis"

  # Rocky 9 EFI GRUB edit mode: 'e' opens the first entry for editing.
  # The linuxefi line is typically 2 downs from the top of the edit buffer.
  # If the install stalls without starting, try bumping <down> count to 3.
  boot_command = [
    "e<wait>",
    "<down><down><end>",
    " inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${var.ks_file}",
    "<f10><wait>"
  ]
  boot_wait = "${var.boot_wait}"

  playbook_file   = "${var.playbook_file}"
  extra_arguments = "${var.extra_arguments}"
  inline          = "${var.inline}"
}