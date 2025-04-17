install_unbound
=========

This role installs the Unboud DNS resolver with a hardened configuration file based on pfSense's defaults. It also enables DNS logging along with DNS over TLS to the DNS resolver(s) of your choice defined in `defaults/main.yml`. By default this includes Cloudflare and Quad9. Options for Google and NextDNS are also available.


### DNS Setup

**Cloudflare**

- [Setup](https://developers.cloudflare.com/1.1.1.1/encryption/dns-over-tls/)
- [Verify](https://one.one.one.one/help)

**Quad9**

- [Setup](https://docs.quad9.net/services/)
- [Verify](https://docs.quad9.net/FAQs/)

**Google**

- [Setup](https://developers.google.com/speed/public-dns/docs/dns-over-tls)
- [Verify](https://developers.google.com/speed/public-dns/docs/using#testing)

**NextDNS**

- [Profile](https://nextdns.io/)
- [Setup](https://github.com/nextdns/nextdns/wiki/pfSense)
- [Verify](https://test.nextdns.io/)


### Reading Logs

You can follow logs with `tail` on Ubuntu:

```bash
sudo tail -f /var/log/syslog | grep 'unbound'
```

On systems without `/var/log/syslog`, like Kali, you can follow unbound logs with `journalctl`:

```bash
sudo journalctl -u unbound -f
```

With the default apparmor profiles applied in both Ubuntu and Kali, you cannot change the logging destination to a file.

If apparmor is not enabled for unbound, you can change the following lines in `unbound.conf` to write logs to a file path:

```conf
	use-syslog: no
	logfile: "/var/log/unbound.log"
```

Then create the logfile:

```bash
sudo touch /var/log/unbound.log
sudo chown unbound:unbound /var/log/unbound.log
```

Finally restarting unbound:

```bash
sudo systemctl restart unbound
```

Requirements
------------

If installing in WSL, ensure you have [WSL2 with systemd](https://learn.microsoft.com/en-us/windows/wsl/wsl-config#systemd-support).

```powershell
# Will install WSL2 by default
wsl --install
```

If upgrading an existing WSL install:

```powershell
wsl --update
wsl --shutdown
wsl --status
wsl
```

Create `/etc/wsl.conf` within you WSL instance if it's missing, add the following lines:

```
[boot]
systemd=true
```

Role Variables
--------------

You'll want to set these in your inventory files.

- `dns_resolvers: ["cloudflare", "quad9"]` List of DNS resolvers to use. NextDNS requires a profile string. Options: google, cloudflare, quad9, nextdns
- `nextdns_profile: null` Replace `null` with your NextDNS profile ID string in quotes.

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
    - role: "install_unbound"
```

Have the `install_unbound/` folder in the same directory as the playbook.yml file.

Run with: `ansible-playbook [-i inventory/inventory.ini] --ask-become-pass -v playbook.yml`

License
-------

MIT

Author Information
------------------

https://github.com/straysheep-dev/ansible-configs
