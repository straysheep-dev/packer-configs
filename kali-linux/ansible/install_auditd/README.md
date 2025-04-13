install_auditd
=========

Installs and configures `auditd` to adhear to a specified policy on Debian / RedHat family systems.

Optionally installs [`laurel`](https://github.com/threathunters-io/laurel) to post-process logs into JSON.

This role is designed to be run multiple times during the install process, in the event policies need revised when rules fail to load.

If you do not supply your own rule file(s), then one of the premade compliance rulesets that ship with auditd can be specified as a per-group or per-host variable in an inventory file.

Requirements
------------

root / sudo access to the remote hosts.

Role Variables
--------------

Set each value in your inventory file per host, or per group.

```conf
install_ruleset: "local"                 # local|stig|pci|ospp
install_ruleset_plus_base: "enabled"     # enabled|disabled, installs the 10-base-config.rules and 99-finalize.rules, set to "disabled" if your local file contains these
default_rules_path: /etc/audit/rules.d/  # Change this if yours is different
log_format: "ENRICHED"                   # ENRICHED or RAW, use ENRICHED if reviewing logs on another system
max_log_file: "8"                        # 8MB total file size per log file, a good default
num_logs: "10"                           # 10 total log files, default for an endpoint shipping logs to a SIEM, use 50+ for a log server
```

*If your custom rule files already contain the following base and finalize rule blocks, set `install_ruleset_plus_base: "disabled"`.*

- [10-base-config.rules](https://github.com/linux-audit/audit-userspace/blob/master/rules/10-base-config.rules)
- [99-finalize.rules](https://github.com/linux-audit/audit-userspace/blob/master/rules/99-finalize.rules)


[**Laurel Options**](https://github.com/threathunters-io/laurel/blob/master/INSTALL.md)

```conf
install_laurel: "false"      # Set to true to install laurel
laurel_binary_type: "glibc"  # musl|glibc Choose between the statically linked musl version, or the dynamically linked glibc version
```

Example inventory file:

```yml
stig_nodes:
  hosts:
    192.168.0.20:
      ansible_port: 22
      ansible_user: admin
      ansible_become_password: "{{ stig_admin_sudo_pass }}"

  vars:
    install_ruleset: "stig"
    install_ruleset_plus_base: "enabled"
    default_rules_path: /etc/audit/rules.d/
    log_format: "ENRICHED"
    max_log_file: "8"
    num_logs: "10"
    install_laurel: "true"
    laurel_binary_type: "musl"

pci_nodes:
  hosts:
    192.168.0.21:
      ansible_port: 22
      ansible_user: admin
      ansible_become_password: "{{ pci_admin_sudo_pass }}"

  vars:
    install_ruleset: "pci"
    install_ruleset_plus_base: "enabled"
    default_rules_path: /etc/audit/rules.d/
    log_format: "ENRICHED"
    max_log_file: "8"
    num_logs: "10"
    install_laurel: "false"

siem_nodes:
  hosts:
    10.99.99.20:
      ansible_port: 22
      ansible_user: root

  vars:
    install_ruleset: "local"
    install_ruleset_plus_base: "enabled"
    default_rules_path: /etc/audit/rules.d/
    log_format: "ENRICHED"
    max_log_file: "8"
    num_logs: "250"
    install_laurel: "true"
    laurel_binary_type: "glibc"
```

Dependencies
------------

None.

Example Playbook
----------------

```yml
- name: "Default Playbook"
  hosts: all
  roles:
    - role: "install_auditd"
```

Execute with:

```bash
ansible-playbook -i "localhost," -c local --ask-become-pass -v ./playbook.yml
```

If `augenrules --check; augenrules --load` has any issues, the play will fail with a non-zero return code.

If this happens investigate manually:

- Run `augenrules --check; augenrules --load` (running the playbook with `-v` also works here)
- Review the lines in `/etc/audit/audit.rules`
- You can directly modify the rule files in `/etc/audit/rules.d` per-host, **but it's better to make and maintain changes in a way so they'll be deployed by this role**.
- Run the playbook again and check for additional errors

License
-------

MIT: All files *besides `tasks/install-laurel.yml`* are released under the MIT license.

[BSD-3-Clause](https://github.com/IppSec/parrot-build/tree/master/roles/configure-logging#license): Many sections of `tasks/install-laurel.yml` were taken and adapted from the logging role of [IppSec's parrot-build](https://github.com/IppSec/parrot-build/blob/master/roles/configure-logging/tasks/auditd.yml), which covers the essential [installation steps for laurel](https://github.com/threathunters-io/laurel/blob/master/INSTALL.md). That task will remain under the BSD-3-Clause.

Author Information
------------------

[straysheep-dev/ansible-configs](https://github.com/straysheep-dev/ansible-configs/)
