build_ubuntu_desktop
=========

Configures a general purpose desktop environment for Ubuntu (GNOME).

- Installs an essential list of apt packages (`tasks/apt.yml`)
- Installs and configures a set of snap packages (`tasks/snap.yml`)
- Wireshark is configured to run without root, the `ansible_facts['env']['USER']` is added to the `wireshark` group
- Copies a set of scripts frequently used to `/usr/local/bin/` (`tasks/files.yml`)
- Installs a policy file for Firefox (`files/firefox-policies.json`)

Requirements
------------

Requires *a minimal installation* of Ubuntu 20.04 or more recent running GNOME.

If you chose a default install instead of a minimal install this role should still work, but on virtual machines there will be two copies of `libreoffice` since this role prefers the `snap` confined version.

18.04 may work, originally this role was a shell script written for 18.04, but some more recent packages may be missing or not configure correctly. One example of this is the unbound DNS resolver. Some features are missing in 18.04's version of unbound, which breaks the configuration used since moving to 20.04. Installing unbound (like other components from the original shell script) is now its own role separate from this one. GNOME may also not be required, but other desktops were not tested.

Role Variables
--------------

None.

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
    - role: build_ubuntu_desktop
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
