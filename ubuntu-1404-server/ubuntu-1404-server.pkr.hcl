# ubuntu-1404-server.pkr.hcl

# [Packer Block: Packer](https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/packer)
packer {
  required_plugins {
    qemu = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/qemu"
    }
    ansible = {
      version = ">= 1.1.2"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

# [Packer Block: Source](https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/source)
source "qemu" "ubuntu-1404-server" {
  vm_name           = "${local.vm_name}"

  iso_target_path   = "${var.iso_storage_path}"
  iso_checksum      = "${local.iso_checksum}"
  iso_urls          = "${local.iso_urls}"

  http_directory   = "${local.http_directory}"
  #http_port_min    = "${local.http_port_min}"
  #http_port_max    = "${local.http_port_max}"

  output_directory  = "${local.output_directory}"
  shutdown_command  = "${local.shutdown_command}"
  headless          = "${local.headless}"

  ssh_password      = "${local.ssh_password}"
  ssh_username      = "${local.ssh_username}"
  ssh_timeout       = "${local.ssh_timeout}"

  #cpus             = "${local.cpus}"
  sockets           = "${local.sockets}"
  cores             = "${local.cores}"
  threads           = "${local.threads}"

  #machine_type     = "${local.machine_type}"
  #accelerator      = "${local.accelerator}"
  memory            = "${local.memory}"
  disk_size         = "${local.disk_size}"
  disk_discard      = "${local.disk_discard}"
  disk_compression  = "${local.disk_compression}"
  format            = "${local.format}"
  qemuargs          = "${local.qemuargs}"

  efi_firmware_code = "${local.efi_firmware_code}"
  efi_firmware_vars = "${local.efi_firmware_vars}"
  efi_boot          = "${local.efi_boot}"

  boot_command = "${local.boot_command}"
  boot_wait = "${local.boot_wait}"
}

# [Packer Block: Build](https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build)
build {
  name    = "${local.vm_name}"
  sources = ["source.qemu.ubuntu-1404-server"]

  provisioner "shell" {
    inline = "${local.inline}"
  }
}