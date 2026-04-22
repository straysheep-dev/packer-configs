# Rocky Packer Templates

The structure of the packer templates for Rocky is derived from other templates in this monorepo (specifically the Ubuntu template). See the other README's for more context.

In summary: the Kickstart files under the [`http/`](./http/) folder are minimal, and [Ansible](./ansible/) is the main provisioning engine for customization. Modify the [`rocky-*.yml`](./ansible/) playbooks for the version you're building as needed.

Supported build inventory:

- [Rocky 9 Server + Desktop](https://rockylinux.org/download) ✅
- [Rocky 10 Server + Desktop](https://rockylinux.org/download) ✅
