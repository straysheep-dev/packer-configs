Role Name
=========

Installs the [ykman](https://github.com/Yubico/yubikey-manager) CLI utilty (yubikey-manager) via `pipx`, `pip`, or the Ubuntu PPA.

[Manual install instructions](https://github.com/Yubico/yubikey-manager?tab=readme-ov-file#installation):

```bash
sudo apt update
sudo apt install -y libpcsclite-dev swig pcscd scdaemon

# 24.04 or later
sudo apt install -y pipx
pipx ensurepath
pipx install yubikey-manager

# 22.04 or earlier
sudo apt insall -y python3-pip
python3 -m pip install --user yubikey-manager
```

Requirements
------------

- [UDEV rules for Yubikey access](https://github.com/Yubico/yubikey-manager/blob/main/doc/Device_Permissions.adoc)
- pcscd running
- swig and PCSC lite development package

Role Variables
--------------

Set to `"true"` to install `ykman` from the Ubuntu PPA.

```conf
use_ppa: "false"
```

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
    - role: "install_ykman"
```

Run with: `ansible-playbook [-i inventory/inventory.ini] -b --ask-become-pass -v playbook.yml`

License
-------

MIT

Author Information
------------------

[straysheep-dev/ansible-configs](https://github.com/straysheep-dev/ansible-configs)
