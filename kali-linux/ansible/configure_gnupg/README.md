configure_gnupg
=========

[Installs a hardened configuration for GnuPG](https://github.com/drduh/YubiKey-Guide?tab=readme-ov-file#configuration), adds support to your shell via `~/.bashrc`. This allows you to use GPG keys for SSH. It also includes a shell script to "refresh" access to a smartcard (Yubikey) if for example the card becomes disconnected (sometimes the case on WSL if putting a laptop into sleep / suspend), or you're switching between cards that do not share the same identity. The script can also be used to just refresh the connection to the gpg-agent in general.

- [gpg.conf](https://github.com/drduh/config/blob/master/gpg.conf)
- [gpg-agent.conf](https://github.com/drduh/config/blob/master/gpg-agent.conf)
- [.bashrc](https://github.com/straysheep-dev/linux-configs/blob/main/gnupg/gpg-bashrc)
- [refresh-smartcard.sh](https://github.com/straysheep-dev/linux-configs/blob/main/gnupg/refresh-smartcard.sh)

Once installed, sourcing your `.bashrc` file will use the following environment variables:

```
SSH_AUTH_SOCK=/run/user/1234/gnupg/S.gpg-agent.ssh
GPG_TTY=/dev/pts/X
```

Tested on Ubuntu 18.04+, Kali 2023.X+ and Fedora 38+.

If you'd like to test this, [generate a key with the following code snippet adapted from Dr Duh's Yubikey Guide](https://github.com/drduh/YubiKey-Guide?tab=readme-ov-file#identity):

```bash
IDENTITY='test test@localhost'
KEY_TYPE=rsa4096
EXPIRATION=2y
CERTIFY_PASS=password123

# Generate the certify key
gpg --batch --passphrase "$CERTIFY_PASS" \
    --quick-generate-key "$IDENTITY" "$KEY_TYPE" cert never

KEYID=$(gpg -k --with-colons "$IDENTITY" | awk -F: '/^pub:/ { print $5; exit }')
KEYFP=$(gpg -k --with-colons "$IDENTITY" | awk -F: '/^fpr:/ { print $10; exit }')

# Generate an auth subkey
for SUBKEY in auth ; do \
  gpg --batch --pinentry-mode=loopback --passphrase "$CERTIFY_PASS" \
      --quick-add-key "$KEYFP" "$KEY_TYPE" "$SUBKEY" "$EXPIRATION"
done

# Needs to be the keygrip of the authenticaton key
KEYGR=$(gpg -k --with-colons --with-keygrip "$IDENTITY" | awk -F: '/^grp:/ { print $10 }' | tail -n 1)

gpg --export-ssh-key "$IDENTITY" | tee -a ~/.ssh/authorized_keys
echo "$KEYGR" | tee -a ~/.gnupg/sshcontrol
```

Now try to ssh into localhost. It should succeed.

To delete the test key:

```bash
gpg --delete-secret-keys "$IDENTITY"
gpg --delete-keys "$IDENTITY"
sed -i "s/$KEYGR//g" ~/.gnupg/sshcontrol
```

Requirements
------------

**IMPORTANT**: If `ssh-add -L` does not show a public key for an authentication subkey, [you may need to add the keygrip of the gpg key to `~/.gnupg/sshcontrol`](https://www.gnupg.org/documentation/manuals/gnupg-2.0/Agent-Configuration.html).

GnuPG installed (this is installed by default on most distros). This role will also install any other dependancies such as the `pcscd` utilities.

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
    - role: configure_gnupg
```

Run with:

```bash
ansible-playbook -i <inventory> --ask-become-pass -v ./playbook.yml
```

License
-------

- MIT (straysheep-dev)
- [MIT (dr duh)](https://github.com/drduh/YubiKey-Guide?tab=MIT-1-ov-file#readme)

Author Information
------------------

https://github.com/straysheep-dev/ansible-configs
