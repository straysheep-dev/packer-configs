configure_ssh
=========

This role conifgures both, the ssh server and it's components as well as the ssh default client configuration.

You can either run the "minimal" tasks to just enforce public key auth, or run the "compliance" tasks to apply a number of security options suggested by CIS, STIG, and other configuration guides. It also installs a [custom login banner](files/issue). The default is "compliance".

The following resources were used to build [files/sshd_config](files/sshd_config):

- [Ubuntu 22.04 Server CIS Level 2 Guide](https://static.open-scap.org/ssg-guides/ssg-ubuntu2204-guide-cis_level2_server.html#!)
- [Ubuntu 20.04 STIG Guide](https://static.open-scap.org/ssg-guides/ssg-ubuntu2004-guide-stig.html#!)
- [github.com/drduh/config/sshd_config](https://github.com/drduh/config/blob/main/sshd_config)

Requirements
------------

None.

Role Variables
--------------

All variables are in [defaults/main.yml](defaults/main.yml).

**ssh_config_choice**

Options are `"compliance"` (default) or `"minimal"`.

- `minimal`: Just enforces public key authentication by revoking password authentication.
- `comliance`: Applies a mix of CIS Level 2, STIG, and other changes to lock SSH down without sacrificing usability.


Dependencies
------------

None.

Example Playbook
----------------

playbook.yml:

```yml
- name: "Example Playbook"
  hosts:
    localhost
  roles:
    - role: "configure_ssh"
```

Have the `configure_systemd_ssh/` folder in the same directory as the playbook.yml file.

Run with: `ansible-playbook [-i inventory/inventory.ini] --ask-become-pass -v playbook.yml`

License
-------

MIT

Author Information
------------------

https://github.com/straysheep-dev/ansible-configs