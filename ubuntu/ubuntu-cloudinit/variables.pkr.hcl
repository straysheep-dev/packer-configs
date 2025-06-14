# variables.pkr.hcl

variable "disk_file" {
  type        = string
  description = "Name of the virtual machine. Affects disk image output files and hostname."
}
variable "iso_storage_path" {
  type        = string
  description = "Literal path to the Ubuntu ISO image for this build."
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
  vm_name = "${var.disk_file}"

  iso_target_path = "${var.iso_storage_path}"
  iso_checksum    = "sha256:45f873de9f8cb637345d6e66a583762730bbea30277ef7b32c9c3bd6700a32b2"
  iso_urls = [
    "file://${var.iso_storage_path}",
    "https://old-releases.ubuntu.com/releases/22.04/ubuntu-22.04.4-live-server-amd64.iso"
  ]

  cd_files = [
    "../http/meta-data",
    "../http/user-data"
  ]
  cd_label = "cidata"

  #http_directory = "http"
  #http_port_min = 3000
  #http_port_max = 3000

  output_directory = "${var.output_directory}"
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now" # This is echoing the password "packer" over to sudo -S shutdown ...
  headless         = false                                     # Set to true if you are running Packer on a Linux server without a GUI, if you are connected via SSH, or running a CI/CD workflow

  ssh_password = "packer"
  ssh_username = "user1"
  ssh_timeout  = "60m"
  #ssh_private_key_file = "~/.ssh/id_rsa" # Path to a private key file, you can use ~ in the path string.

  # cpus  = 4 # This is the equivalent of sockets * cores * threads, cores are preferred over sockets for this value
  sockets = 1 # Number of virtual CPUs
  cores   = 4 # Number of cores per CPU
  threads = 4 # Threads, 1 per core

  machine_type     = "q35"   # As of now, q35 is required for secure boot to be enabled
  accelerator      = "kvm"   # This may be none, kvm, tcg, hax, hvf, whpx, or xen
  memory           = 8192    # 4096 is a good size for testing, use 8192 or more for a persistent desktop
  disk_size        = "64G"   # 16G is a good size for testing, use 32G or 64G for a persistent VM, you can always attach more virtual disks
  disk_discard     = "unmap" # unmap or ignore, default is ignore
  disk_compression = true    # Apply compression to the QCOW2 disk file using qemu-img convert. Defaults to false.
  format           = "qcow2" # Either qcow2 or raw
  #  qemuargs = [
  #    ["-cpu", "host"],
  #    ["-machine", "q35,smm=on,accel=kvm:hvf:whpx:tcg"],
  #    ["-global", "driver=cfi.pflash01,property=secure,value=on"],
  #    ["-object", "rng-random,filename=/dev/urandom,id=rng0"]
  #  ]

  efi_firmware_code = "/usr/share/OVMF/OVMF_CODE_4M.secboot.fd"
  efi_firmware_vars = "/usr/share/OVMF/OVMF_VARS_4M.ms.fd" # efivars with MS keys built-in, writes a copy next to the VM img file
  efi_boot          = true

  vtpm            = true
  tpm_device_type = "tpm-tis"

  boot_command = [
    "e<wait>",
    "<down><down><down><end>",
    " autoinstall ",
    " --- ",
    "<f10>"
  ]
  boot_wait = "10s"

  playbook_file   = "${var.playbook_file}"
  extra_arguments = "${var.extra_arguments}"
  inline          = "${var.inline}"
}