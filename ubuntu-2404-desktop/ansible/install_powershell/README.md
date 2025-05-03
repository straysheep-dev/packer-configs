install_powershell
=========

Installs the [latest PowerShell version](https://github.com/PowerShell/PowerShell/releases) for Linux and Windows.

- [Official Documentation](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux?view=powershell-7.4)

Requirements
------------

Either Windows or a [supported Linux distribution](https://packages.microsoft.com/). Most Debian and RedHat family OS's are supported.

**IMPORTANT**: On recent versions of Fedora, `sysmonforlinux` and `powershell` are not available through Microsoft's feed for Fedora. However, both of these packages can be installed from Microsoft's feed for RHEL. USE THIS AT YOUR OWN RISK. Both packages were tested in a lab environment on Fedora 40, from RHEL 9's package feed.

Taken from [Sysinternals/SysmonForLinux](https://github.com/Sysinternals/SysmonForLinux/blob/main/INSTALL.md#rhel-9):

```bash
sudo rpm -Uvh https://packages.microsoft.com/config/rhel/9/packages-microsoft-prod.rpm
sudo dnf install -y powershell

# or from GitHub, using the sliver intaller method
# https://github.com/BishopFox/sliver/blob/master/docs/sliver-docs/public/install#L98

AUTHOR_REPO_LIST='PowerShell/PowerShell'

RPM_FILE='powershell-[0-9].*.rh.x86_64.rpm'
CHECKSUM_FILE='hashes.sha256'

for AUTHOR_REPO in $AUTHOR_REPO_LIST
do
	ARTIFACTS=$(curl -s https://api.github.com/repos/"$AUTHOR_REPO"/releases/latest | awk -F '"' '/browser_download_url/{print $4}')
	for URL in $ARTIFACTS
	do
		ARCHIVE=$(basename "$URL")
		# Download files first
		if [[ "$ARCHIVE" =~ ^($RPM_FILE|$CHECKSUM_FILE)$ ]]; then
			echo "[*]Downloading $ARCHIVE..."
			curl --silent -L "$URL" --output "$ARCHIVE"
		fi
	done
done
# Check the sha256sum
if (sha256sum -c "$CHECKSUM_FILE" --ignore-missing); then
	echo "[OK] SHA256SUM"
else
	echo "[WARNING] SHA256SUM MISMATCH"
	exit 1
fi
sudo dnf install -y ./powershell-*.rpm
```

Role Variables
--------------

None.

Dependencies
------------

This role depends on the `configure_microsoft_repos` role executing when the target system is Linux.

Example Playbook
----------------

Playbook file:

```yml
- name: "Default Playbook"
  hosts:
    all
  roles:
    - role: configure_microsoft_repos
    - role: install_powershell
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
