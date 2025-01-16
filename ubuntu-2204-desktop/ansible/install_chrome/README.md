Role Name
=========

Installs Google Chrome directly from Google's Linux repository, and includes a hardened policy file.

- https://www.google.com/linuxrepositories/
- [Latest Signing Key (Google Link)](https://dl.google.com/linux/linux_signing_key.pub)
- [Latest Signing Key (Keyserver Link)](https://keyserver.ubuntu.com/pks/lookup?search=EB4C1BFD4F042F6DDDCCEC917721F63BD38B4796&fingerprint=on&op=index)
- [Policy File](https://github.com/straysheep-dev/linux-configs/tree/main/web-browsers/chromium)

Requirements
------------

Tested on Ubuntu >= 18.04, Kali >= 2023.x, Fedora 40.

Systems must have `apt` versions later than 1.4, according to the installation instructions:

> On systems with older versions of apt (i.e. versions prior to 1.4), the ASCII-armored format public key must be converted to binary format before it can be used by apt.

Role Variables
--------------

None.

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
    - role: "install_chrome"
```

Have the `install_chrome/` folder in the same directory as the playbook.yml file.

Run with: `ansible-playbook [-i inventory/inventory.ini] --ask-become-pass -v playbook.yml`

License
-------

MIT

Author Information
------------------

https://github.com/straysheep-dev/ansible-configs
