# variables.pkr.hcl

# [Input Variables and local variables](https://developer.hashicorp.com/packer/guides/hcl/variables)

# [Packer Block: Variables](https://developer.hashicorp.com/packer/docs/templates/hcl_templates/variables)
variable "iso_storage_path" {
  type    = string
  default = "file:///home/user/iso/"
}

variable "vm_hostname" {
  type    = string
  default = "ubuntu-1604"
}

variable "vm_name" {
  type = string
  default = "ubuntu-1604-server"
}

locals {
  vm_name = "${var.vm_name}"

  # [ISO Configuration](https://developer.hashicorp.com/packer/integrations/hashicorp/qemu/latest/components/builder/qemu#iso-configuration)
  # The iso_target_path is where the ISO file is saved to disk locally.
  # You can point this path to your existing ISO storage path.
  iso_target_path = "${var.iso_storage_path}"
  iso_checksum = "sha256:16afb1375372c57471ea5e29803a89a5a6bd1f6aabea2e5e34ac1ab7eb9786ac"
  iso_urls      = [
    "${var.iso_storage_path}",
    "https://old-releases.ubuntu.com/releases/16.04.6/ubuntu-16.04.6-server-amd64.iso"
  ]

  # [HTTP Directory Configuration](https://developer.hashicorp.com/packer/integrations/hashicorp/qemu/latest/components/builder/qemu#http-directory-configuration)
  # This will serve the files under http/ here.
  # Packer spins up an HTTP server for this automatically. Review firewall rules on the Packer host.
  # These lines have been commented out to use a seed.img ISO file instead.
  http_directory = "http"
  #http_port_min = 3000
  #http_port_max = 3000

  # Where the resulting artifacts from a build are written
  output_directory = "build"
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now" # This is echoing the password "ubuntu" over to sudo -S shutdown ...
  headless         = false # Set to true if you are running Packer on a Linux server without a GUI, if you are connected via SSH, or running a CI/CD workflow

  # [SSH Configuration](https://developer.hashicorp.com/packer/integrations/hashicorp/qemu/latest/components/builder/qemu#optional-ssh-fields:)
  ssh_password         = "packer"
  ssh_username         = "user1"
  ssh_timeout          = "60m"
  #ssh_private_key_file = "~/.ssh/id_rsa" # Path to a private key file, you can use ~ in the path string.

  # [CPU Configuration](https://developer.hashicorp.com/packer/integrations/hashicorp/qemu/latest/components/builder/qemu#smp-configuration)
  # cpus  = 4 # This is the equivalent of sockets * cores * threads, cores are preferred over sockets for this value
  sockets = 1 # Number of virtual CPUs
  cores   = 4 # Number of cores per CPU
  threads = 4 # Threads, 1 per core

  # [Qemu Configurations](https://developer.hashicorp.com/packer/integrations/hashicorp/qemu/latest/components/builder/qemu#qemu-specific-configuration-reference)
  #machine_type     = "q35" # As of now, q35 is required for secure boot to be enabled
  #accelerator      = "kvm" # This may be none, kvm, tcg, hax, hvf, whpx, or xen
  memory           = 8192 # 4096 is a good size for testing, use 8192 or more for a persistent desktop
  disk_size        = "64G" # 16G is a good size for testing, use 32G or 64G for a persistent VM, you can always attach more virtual disks
  disk_discard     = "ignore" # unmap or ignore, default is ignore
  disk_compression = true # Apply compression to the QCOW2 disk file using qemu-img convert. Defaults to false.
  format           = "qcow2" # Either qcow2 or raw
  qemuargs = [
    ["-cpu", "host"],
    ["-machine", "q35,smm=on,accel=kvm:hvf:whpx:tcg"],
    ["-global", "driver=cfi.pflash01,property=secure,value=on"],
    ["-object", "rng-random,filename=/dev/urandom,id=rng0"]
  ]

  # [EFI Boot Configuration](https://developer.hashicorp.com/packer/integrations/hashicorp/qemu/latest/components/builder/qemu#efi-boot-configuration)
  # See: https://github.com/hashicorp/packer-plugin-qemu/issues/97
  efi_firmware_code = "/usr/share/OVMF/OVMF_CODE_4M.fd"
  efi_firmware_vars = "/usr/share/OVMF/OVMF_VARS_4M.fd" # efivars with MS keys built-in, writes a copy next to the VM img file
  efi_boot          = true

  # [Boot Configuration](https://developer.hashicorp.com/packer/integrations/hashicorp/qemu/latest/components/builder/qemu#boot-configuration)
  # Emulating literal key presses when booting the system.
  # For various boot command examples: https://developer.hashicorp.com/packer/docs/community-tools#templates
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

  # Adjust as needed based on how fast your environment can boot the machine
  boot_wait = "10s"

  inline = [
      "echo 'packer' | sudo -S sed -i /etc/default/grub -e 's/GRUB_CMDLINE_LINUX_DEFAULT=\".*/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash\"/'",
      "echo 'packer' | sudo -S update-grub",
      "echo 'packer' | sudo -S apt update",
      "echo 'packer' | sudo -S DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a apt full-upgrade -y",
  ]
}