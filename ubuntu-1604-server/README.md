# ubuntu-16.04-server

A packer template for a standard Ubuntu 16.04 server.

> [!NOTE]
> In testing this build, some images required booting into the recovery kernel first, then simply proceeding to boot normally without doing anything else in the recovery menu. Otherwise the image never fully booted before doing these two steps. It's unclear why this is the case, but it has happened frequently.


## References

This template was built by referencing the following resources:

- [HashiCorp Ubuntu Preseed Examples](https://developer.hashicorp.com/packer/guides/automatic-operating-system-installs/preseed_ubuntu#examples)
- [debian.org/DebianInstaller/Preseed](https://wiki.debian.org/DebianInstaller/Preseed)
- [debian.org example-preseed.txt Template](https://www.debian.org/releases/stable/example-preseed.txt)
- [github.com/shantanoo-desai/packer-ubuntu-server-uefi](https://github.com/shantanoo-desai/packer-ubuntu-server-uefi/blob/main/templates/ubuntu.pkr.hcl)
- [HashiCorp QEMU Builder Examples](https://developer.hashicorp.com/packer/integrations/hashicorp/qemu/latest/components/builder/qemu#basic-example)
- [Ansible: Installation Guide Using pipx](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#pipx-install)
- [Ansible Community Changelogs](https://docs.ansible.com/ansible/latest/reference_appendices/release_and_maintenance.html#ansible-community-changelogs)


## Building

Ubuntu releases prior to 18.04 have more in common with Debian than modern Ubuntu distros in that they require the use of a `preseed.cfg` file for automated provisioning. The options are not that different than the default Debian options, and the [HashiCorp Ubuntu preseed examples](https://developer.hashicorp.com/packer/guides/automatic-operating-system-installs/preseed_ubuntu#examples) detailed above point out the few differences in the sources URLs plus skipping the warning about weak passwords and encyrpting the home directory if you're using "packer" as the build password.

In other words, there is no cloud-init or ability to provision these older Ubuntu versions with a seed.img ISO file.


### Ansible Provisioning

The latest versions of Ansible will not execute on systems with older versions of python3 installed. You'll see an error similar to this, where it isn't even able to print the required version information:

```bash
fatal: [10.10.10.55]: FAILED! => {"ansible_facts": {}, "changed": false, "failed_modules": {"ansible.legacy.setup": {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python3"}, "exception": "Traceback (most recent call last):

<SNIP>

  File \"/tmp/ansible_ansible.legacy.setup_payload_zlebszdb/ansible_ansible.legacy.setup_payload.zip/ansible/module_utils/basic.py\", line 17
    msg=f\"ansible-core requires a minimum of Python version {'.'.join(map(str, _PY_MIN))}. Current version: {''.join(sys.version.splitlines())}\",

```

You will need to install an older version of `anisble-core`. `pipx` is recommended for ease of use and deployment:

```bash
# ansible-core
version_number="2.13.0"
package_name="ansible-core"
pipx install --suffix=_"$version_number" "$package_name"=="$version_number"

# Execute this version like this
ansible-playbook_2.13.0 -i "127.0.0.1," -e "....
```

> [!TIP]
> The versions found to be the most successful for these use cases are Ansible 2.13.0 or above.

To remove any versions you may have installed for testing (pipx):

```bash
version_number="2.12.10"
package_name='ansible-core' # or ansible-core
pipx uninstall "$package_name"_"$version_number"
```


### Compatability Issues

Keep in mind many configuration files built on newer systems will need to be back-ported to work with older versions of the their software. The Unbound DNS resolver is a good example, where only newer versions support DNS over TLS and HTTPS.
