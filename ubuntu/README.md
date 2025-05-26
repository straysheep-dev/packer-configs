# Ubuntu Packer Templates

The build templates and set of variable files in this directory are an attempt to standardize all Ubuntu images under as few "parent" templates as possible, where the variable files and any Ansible playbooks are unique to each version release. This will help reduce maintenance efforts, and improve customization behind the various build scripts here which are premade examples in the form of `bash` scripts calling `packer`.

> [!NOTE]
> Primary templates end in `.pkr.hcl`, are always loaded during the build, and initialize variables for the `.pkrvars.hcl` files to use.

- `ubuntu-preseed.pkr.hcl` is the builder file for all preseed-based builds
- `ubuntu-cloudinit.pkr.hcl` is the builder file for all cloudinit-based builds
- Separate `variables.pkr.hcl` files exists for both, the preseed and cloudinit installer builder templates

In other words, we're just separating out the `.pkr.hcl` information into two files: the builder blocks, and the variable blocks. These could be in one file but this makes them easier to read and maintain.

Variables files that change per-build end in `pkrvars.hcl`. These pass through unique values for the relevant build to `variables.pkr.hcl`.

Supported build inventory:

- Ubuntu 14.04 Server
- Ubuntu 16.04 Server
- Ubuntu 18.04 Server
- Ubuntu 20.04 Server + Desktop
- Ubuntu 22.04 Server + Desktop
- Ubuntu 24.04 Server + Desktop

> [!WARNING]
> This directory is still a work-in-progress. Once the existing Ubuntu builds are ported over to this format, the README will contain all of their notes for reference, and any unique settings or requirements.


## References

This template was built by referencing the following resources (in addition to those listed in the README at the root of this repo):

- [github.com/shantanoo-desai/packer-ubuntu-server-uefi](https://github.com/shantanoo-desai/packer-ubuntu-server-uefi/blob/main/templates/ubuntu.pkr.hcl)
- [HashiCorp QEMU Builder Examples](https://developer.hashicorp.com/packer/integrations/hashicorp/qemu/latest/components/builder/qemu#basic-example)

The idea for the desktop templates is based on the work documentated under [github.com/canonical/autoinstall-desktop](https://github.com/canonical/autoinstall-desktop/blob/main/autoinstall.yaml), which is an excellent reference but is outdated. For example you don't need to uninstall anything (it's a preference to leave server utilities installed in the desktop environment) and the default snaps are now installed automatically with the `ubuntu-desktop-minimal` package.

> [!TIP]
> With Packer, it's often easier to use Packer itself (and cloud-init) to simply install the VM with as few modifications as possible, and then configure it later with the various provisioners. Cloud-init in particular can be very tricky to work with when combined with Packer.


## Network Issues

The most common issues you will encounter with packer builds revolve around these things:

- hostname is "localhost"
- /etc/hosts file is wrong or doesn't exist
- network interface is different after build
- systemd-networkd (netplan) vs NetworkManager

Some of these are the cause of long boot times or the lack of a network connection on first boot. In most cases you'll want to handle setting things correctly using either the Ansible or shell provisioners. If you aren't using the classic network interface names (like `eth0`) you may have to adjust things manually after the first boot.


## Autoinstall and Debian-preseed

[Autoinstall (subiquity)](https://canonical-subiquity.readthedocs-hosted.com/en/latest/index.html) is the new way to build Ubuntu machines without interaction. This format is supported in the following installers:

- Ubuntu Server, version 20.04 and later
- Ubuntu Desktop, version 23.04 and later

Older versions will rely on Debian's [Preseed installer](https://wiki.debian.org/DebianInstaller/Preseed) plaintext file.

- Ubuntu Server, verison 18.04 and earlier
- Ubuntu Desktop, version 22.04 and earlier

> [!NOTE]
> For easier maintenance across all Ubuntu templates here, desktop images are always built using the server image as a base. This creates a smaller image overall, and gives us access to the autoinstall utilities as early as Ubuntu version 20.04.


## Autoinstall and Cloud-init Data Files

There are three ways to inject these files into a packer template:

- Using packer's [`cd_files`](https://developer.hashicorp.com/packer/integrations/hashicorp/qemu/latest/components/builder/qemu#cd-configuration) argument with [`cd_label = "cidata"`](https://cloudinit.readthedocs.io/en/latest/reference/datasources/nocloud.html#source-2-drive-with-labeled-filesystem)
- [Building and mounting a separate ISO manually](https://docs.cloud-init.io/en/latest/reference/datasources/nocloud.html#example-creating-a-disk) (effectively what `cd_files` does for you)
- [HTTP Server](https://developer.hashicorp.com/packer/integrations/hashicorp/qemu/latest/components/builder/qemu#http-directory-configuration)

**cd_files**

This section is used by default on cloud-init machines in this repo for convenience.

```hcl
  cd_label = "cidata"
  cd_files = [
    "./http/meta-data",
    "./http/user-data"
  ]
```

> [!TIP]
> Remember, the `cd_label` must be set as [`cd_label = "cidata"`](https://cloudinit.readthedocs.io/en/latest/reference/datasources/nocloud.html#source-2-drive-with-labeled-filesystem).

**genisoimage**

[To create a mountable ISO manually, use `genisoimage`](https://docs.cloud-init.io/en/latest/reference/datasources/nocloud.html#example-creating-a-disk).

```bash
# https://cloudinit.readthedocs.io/en/latest/howto/launch_qemu.html#create-an-iso-disk
sudo apt update; sudo apt install -y genisoimage
genisoimage \
    -output seed.img \
    -volid cidata -rational-rock -joliet \
    http/user-data http/meta-data
```

You'll need to specify this ISO file in the `qemuargs` block, for example with `["-cdrom", "seed.img"]`.

```hcl
  qemuargs = [
    ["-cpu", "host"],
    ["-machine", "q35,smm=on,accel=kvm:hvf:whpx:tcg"],
    ["-global", "driver=cfi.pflash01,property=secure,value=on"],
    ["-object", "rng-random,filename=/dev/urandom,id=rng0"],
    ["-cdrom", "seed.img"]
  ]
```

> [!WARNING]
>  In some cases the presence of a `qemuargs` block can override your other template settings. This is likely a bug in some versions of packer, and is the reason the example block above has more than just the `"-cdrom"` option included.


## Ansible

There are three files you may want to modify under `ansible/`.

- `pwfile` contains "password123", and unlocks `vault.example.txt`
- `vault.example.txt` is an Ansible vault that contains user1's password of "packer"
- `ubuntu-*.yml` contains the roles to run for each Ubuntu build. You can modify these or simply not use them at all

Create and edit a vault ([you will need Ansible installed](https://github.com/straysheep-dev/ansible-configs?tab=readme-ov-file#setup)):

```bash
ansible-vault create ./ansible/vault.txt

# Edit the vault later
ansible-vault edit ./ansible/vault.txt

# Ensure your new password is written to pwfile
echo '<more-secure-password>' | tee ./ansible/pwfile
```

> [!NOTE]
> The `.gitignore` excludes `*vault.txt` and `*vault.yml`.


### Ansible Secrets + Packer env()

You could alternatively use environment variables with [packers' `env("VARIABLE")` funciton](https://developer.hashicorp.com/packer/docs/templates/hcl_templates/functions/contextual/env).

See these references for a full breakdown, they're summarized below:

- [Enter Vault Password Once for Multiple Playbooks](https://stackoverflow.com/questions/77622261/how-to-pass-a-password-to-the-vault-id-in-a-bash-script)
- [How to Pass an Ansible Vault a Password](https://stackoverflow.com/questions/62690097/how-to-pass-ansible-vault-password-as-an-extra-var/76236662)
- [Get Password from the Environment with `curl`](https://stackoverflow.com/questions/33794842/forcing-curl-to-get-a-password-from-the-environment/33818945#33818945)
- [Get Password from Shell Script without Echoing](https://stackoverflow.com/questions/3980668/how-to-get-a-password-from-a-shell-script-without-echoing#3980904)

First, enter the vault password with `read`:

```bash
echo "Enter Vault Password"; read -r -s vault_pass; export ANSIBLE_VAULT_PASSWORD=$vault_pass
```

- `-s` hides the text as you type
- `-r` interprets any backslashes correctly, see [SC2162](https://www.shellcheck.net/wiki/SC2162)
- The environment variable only appears in the `env` of that shell session
- It does not appear in the history of that shell
- Another shell running under the same user context cannot see that environment variable without a process dump

Ultimately these files aren't the most sensitive if machines aren't being built through GitHub Actions or in some way that can expose real secrets in log files. You should be using Ansible or the shell provisioner to lock down the machine during or after the build as necessary. See the [warning below the ks.cfg section in this Rocky Linux deployment tutorial](https://docs.rockylinux.org/guides/automation/templates-automation-packer-vsphere/#the-kscfg-file).


## Building

To run the build, use the shell script for the relevant Ubuntu version to start packer:

```bash
bash ./build-ubuntu-${VERSION}.sh
```

> [!TIP]
> These try to replicate what's happening over in [StefanScherer/packer-windows](https://github.com/StefanScherer/packer-windows), where these build scripts are essentially preconfigured examples, which allows these templates to be more modular.


## Configuring

The Ansible and shell provisioners in the `build {}` block are responsible for configuration.

Anything you want to change while keeping the overall build template the same would be done there, through the `.pkrvars.hcl` and `ubuntu-*.yml` Anisble playbook files.

Further changes to the overall build would start with the `http/` files before manually editing the .`pkr.hcl` templates themselves. You might do this for example to build a BIOS based system instead of UEFI.


## Running and Importing

To launch the resulting build, whether it's a desktop or server:

```bash
# https://superuser.com/questions/1703377/qemu-kvm-uefi-secure-boot-doesnt-work
# https://wiki.debian.org/SecureBoot/VirtualMachine

output_directory='build_example'
disk_file='ubuntu22.04-desktop'
cd "${output_directory}"/ && \
kvm -no-reboot -m 4096 -smp 4\
  -cpu host \
  -machine q35,smm=on,accel=kvm:hvf:whpx:tcg \
  -global driver=cfi.pflash01,property=secure,value=on \
  -device virtio-net-pci,netdev=net0 \
  -netdev user,id=net0,hostfwd=tcp::2222-:22 \
  -object rng-random,filename=/dev/urandom,id=rng0 \
  -drive file="${disk_file}",format=qcow2,if=virtio \
  -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE_4M.secboot.fd \
  -drive if=pflash,format=raw,file=efivars.fd \
  -vga virtio \
  -display gtk

```

You can also simply point to the disk and efivars file with `virt-manager` as described [here](../README.md#run-completed-builds-with-virt-manager), or any other hypervisor that can read qcow2 images. Otherwise convert the image with qemu utils and import it.

Finally, you can automate importing the build into `virt-manager` with `import-to-virt-manager.sh`. This will import it, shut it down, and take an initial snapshot.
