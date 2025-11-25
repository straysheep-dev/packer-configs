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

source "qemu" "kali-linux" {
  accelerator        = "${local.accelerator}"
  boot_command       = "${local.boot_command}"
  cpus               = "${local.cpus}"
  disk_cache         = "${local.disk_cache}"
  disk_compression   = "${local.disk_compression}"
  disk_detect_zeroes = "${local.disk_detect_zeroes}"
  disk_discard       = "${local.disk_discard}"
  disk_image         = "${local.disk_image}"
  disk_interface     = "${local.disk_interface}"
  disk_size          = "${local.disk_size}"
  efi_boot           = "${local.efi_boot}"
  efi_firmware_code  = "${local.efi_firmware_code}"
  efi_firmware_vars  = "${local.efi_firmware_vars}"
  format             = "${local.format}"
  headless           = "${local.headless}"
  http_directory     = "${local.http_directory}"
  iso_checksum       = "${local.iso_checksum}"
  iso_target_path    = "${local.iso_target_path}"
  iso_urls           = "${local.iso_urls}"
  memory             = "${local.memory}"
  output_directory   = "${local.output_directory}"
  shutdown_command   = "${local.shutdown_command}"
  ssh_password       = "${local.ssh_password}"
  ssh_timeout        = "${local.ssh_timeout}"
  ssh_username       = "${local.ssh_username}"
  vm_name            = "${local.vm_name}"
}

build {
  name    = "${local.vm_name}"
  sources = ["source.qemu.kali-linux"]

  provisioner "shell" {
    inline = "${local.inline}"
  }

  provisioner "ansible" {
    extra_arguments = "${local.extra_arguments}"
    playbook_file   = "${local.playbook_file}"
  }

}
