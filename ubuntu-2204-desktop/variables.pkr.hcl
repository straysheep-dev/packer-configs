# variables.pkr.hcl

# [Input Variables and local variables](https://developer.hashicorp.com/packer/guides/hcl/variables)

# [Packer Block: Variables](https://developer.hashicorp.com/packer/docs/templates/hcl_templates/variables)
variable "iso_storage_path" {
  type    = string
  default = "file:///home/user/iso/"
}

locals {
  vm_name = "ubuntu-2204-desktop"

  # [ISO Configuration](https://developer.hashicorp.com/packer/integrations/hashicorp/qemu/latest/components/builder/qemu#iso-configuration)
  # The iso_target_path is where the ISO file is saved to disk locally.
  # You can point this path to your existing ISO storage path.
  iso_target_path = "${var.iso_storage_path}"
  iso_checksum = "sha256:45f873de9f8cb637345d6e66a583762730bbea30277ef7b32c9c3bd6700a32b2"
  iso_urls      = [
    "${var.iso_storage_path}ubuntu-22.04.4-live-server-amd64.iso",
    "https://old-releases.ubuntu.com/releases/22.04/ubuntu-22.04.4-live-server-amd64.iso"
  ]

  # [HTTP Directory Configuration](https://developer.hashicorp.com/packer/integrations/hashicorp/qemu/latest/components/builder/qemu#http-directory-configuration)
  # This will serve the files under http/ here, as cloud-init data sources.
  # Packer spins up an HTTP server for this automatically. Review firewall rules on the Packer host.
  # These lines have been commented out to use a seed.img ISO file instead.
  #http_directory = "http"
  #http_port_min = 3000
  #http_port_max = 3000

  # Where the resulting artifacts from a build are written
  output_directory = "build"
  shutdown_command = "echo 'ubuntu' | sudo -S shutdown -P now" # This is echoing the password "ubuntu" over to sudo -S shutdown ...
  headless         = false # Set to true if you are running Packer on a Linux server without a GUI, if you are connected via SSH, or running a CI/CD workflow

  # [SSH Configuration](https://developer.hashicorp.com/packer/integrations/hashicorp/qemu/latest/components/builder/qemu#optional-ssh-fields:)
  ssh_password         = "ubuntu"
  ssh_username         = "user1"
  ssh_timeout          = "40m"
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
    ["-object", "rng-random,filename=/dev/urandom,id=rng0"],
    ["-cdrom", "seed.img"]
  ]

  # [EFI Boot Configuration](https://developer.hashicorp.com/packer/integrations/hashicorp/qemu/latest/components/builder/qemu#efi-boot-configuration)
  # See: https://github.com/hashicorp/packer-plugin-qemu/issues/97
  efi_firmware_code = "/usr/share/OVMF/OVMF_CODE_4M.secboot.fd"
  efi_firmware_vars = "/usr/share/OVMF/OVMF_VARS_4M.ms.fd" # efivars with MS keys built-in, writes a copy next to the VM img file
  efi_boot          = true

  # [Boot Configuration](https://developer.hashicorp.com/packer/integrations/hashicorp/qemu/latest/components/builder/qemu#boot-configuration)
  # Emulating literal key presses when booting the system.
  # For various boot command examples: https://developer.hashicorp.com/packer/docs/community-tools#templates
  boot_command = [
    "<wait5>",
    "<enter>",
    "<wait60>",
    "yes<enter>"
  ]

  # When booting from a firmware ROM that enables SecureBoot, it often takes
  # a few seconds longer for the VNC session to connect. If boot commands aren't
  # being executed, it may be because the boot wait time isn't long enough.
  boot_wait = "30s"

  # Run Ansible plays on the target machine.
  # There are two verisons of this; "ansible" and "ansible-local". The latter
  # installs ansible on the target machine.
  # "ansible" (below) will execute plays from the host, toward the target machine
  # without installing Ansible on the target.
  # https://developer.hashicorp.com/packer/integrations/hashicorp/ansible/latest/components/provisioner/ansible
  playbook_file = "./ansible/playbook.yml"
  extra_arguments = [
    "--extra-vars",
    "@./ansible/vault.txt",
    "--vault-password-file=./ansible/pwfile"
  ]
  # Default user must be able to run sudo passwordless for this section to work.
  # That is easily configured in the user-data section of the cloud-init config.
  # These actions could be moved to an Ansible role.
  inline = [
      "sudo sed -i /etc/default/grub -e 's/GRUB_CMDLINE_LINUX_DEFAULT=\".*/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash\"/'",
      "sudo update-grub",
      "sudo apt update",
      "sudo DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a apt full-upgrade -y",
      "sudo apt install -y ubuntu-desktop-minimal"
  ]
}