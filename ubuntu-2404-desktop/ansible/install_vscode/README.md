install_vscode
=========

Installs Visual Studio Code for Linux.

This will default to the [`code-oss` package when executed on Kali](https://www.kali.org/blog/kali-linux-2021-2-release/#new-tools-in-kali). On all other distros it will use the Microsoft package feed as its source to install `code`.

Tested on Ubuntu, Kali, Fedora.

Requirements
------------

A [supported distribution](https://code.visualstudio.com/docs/setup/linux). Most Debian and RedHat family OS's are supported.

**IMPORTANT**: On recent versions of Fedora, `sysmonforlinux` and `powershell` are not available through Microsoft's feed for Fedora. However, both of these packages can be installed from Microsoft's feed for RHEL. USE THIS AT YOUR OWN RISK. Both packages were tested in a lab environment on Fedora 40, from RHEL 9's package feed.

Role Variables
--------------

Configures whether to use the `snap` package manager, mainly for Ubuntu. Default is set to `false`.

- `prefer_snap: "false"`

Dependencies
------------

This role depends on the `configure_microsoft_repos` role executing.

Example Playbook
----------------

Playbook file:

```yml
- name: "Default Playbook"
  hosts:
    all
  roles:
    - role: configure_microsoft_repos
    - role: install_vscode
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
