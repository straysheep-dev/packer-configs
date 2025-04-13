configure_microsoft_repos
=========

Configures the Microsoft Linux software repositories for use with your package manager.

- [Keys](https://packages.microsoft.com/keys/) are obtained and verified first using the known fingerprint before making any additional changes
- [Uses the keys to verify the .deb or .rpm package to complete configuration of the repositories](https://github.com/microsoft/linux-package-repositories#signature-verification)
  - On Debian, this means `debsig-verify /tmp/packages-microsoft-prod.deb` (uses `gpg`, apt_key is deprecated)
  - On RedHat, this means `rpm --checksig /tmp/packages-microsoft-prod.rpm` (uses Ansible's rpm_key module)

[Current GPG package signing key](https://learn.microsoft.com/en-us/linux/packages#how-to-use-the-gpg-repository-signing-key):

```
# https://packages.microsoft.com/keys/microsoft.asc
Public Key ID: Microsoft (Release signing) gpgsecurity@microsoft.com
Public Key Fingerprint: BC52 8686 B50D 79E3 39D3 721C EB3E 94AD BE12 29CF
```

Tested on Debian family (Debian, Ubuntu) and RedHat family (Fedora) distributions.

- https://learn.microsoft.com/en-us/linux/packages
- https://github.com/microsoft/linux-package-repositories

Requirements
------------

A [supported distribution](https://packages.microsoft.com/). Most Debian and RedHat family OS's are supported.

**IMPORTANT**: On recent versions of Fedora, `sysmonforlinux` and `powershell` are not available through Microsoft's feed for Fedora. However, both of these packages can be installed from Microsoft's feed for RHEL. USE THIS AT YOUR OWN RISK. Both packages were tested in a lab environment on Fedora 40, from RHEL 9's package feed.

Role Variables
--------------

Using the [`ansible.builtin.blockinfile` plus the `marker`parameter](https://github.com/ansible/ansible-modules-extras/issues/1592), safely modify the priority of sources for your package manager.

`prioritize_microsoft_feed: "false"`

- Set this to true to prioritize the Microsoft feed over your default package archive's feed.
- You'd do this if for example you prefer the .NET version packaged by Microsoft.
- Defaults to "false" to prevent .NET version conflicts with other packages in your package manager not maintained by Microsoft.

- [Troubleshoot .NET errors](https://learn.microsoft.com/en-Us/dotnet/core/install/linux-package-mixup?pivots=os-linux-redhat)

Dependencies
------------

None.

Example Playbook
----------------

Playbook file:

```yml
- name: "Default Playbook"
  hosts:
    all
  roles:
    - role: configure_microsoft_repos
```

Run with:

```bash
ansible-playbook -i <inventory> --ask-become-pass -v ./playbook.yml
```

License
-------

MIT

Author Information
------------------

https://github.com/straysheep-dev/ansible-configs
