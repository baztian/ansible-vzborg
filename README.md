# borgbackup for vzdump / proxmox ansible role

![CI](https://github.com/baztian/ansible-vzborg/workflows/CI/badge.svg)

Ansible role to install [VzBorg utility](https://github.com/baztian/vzborg) along
with some proper configuration to make sure backups are carried out on a schedule.

It carries out the backup for all configurations except `default`. Only
vms tagged with `backup` or `backup-<configname>` are backed up.
The role initializes each configured repository that defines `VZBORG_REPO`.
It uses that config's passphrase and encryption mode. Existing repositories are
left unchanged; initialization errors, including connection failures, stop the play.

Please make sure to create a backup from the repo key and password after setting
up! E.g. for a config file `local`

    (. /etc/vzborg/default && . /etc/vzborg/local && \
      export BORG_PASSPHRASE="$VZBORG_PASSPHRASE" && \
      borg key export $VZBORG_REPO) > ~/vzborg.borg.key

## Role variables

* `vzborg_init_encryption`: The encryption algorithm to use. Stick to
  default if not provided.
* `vzborg_timer`: The `vzborg.timer`'s `OnCalendar` value. See
  [systemd documentation](https://www.freedesktop.org/software/systemd/man/systemd.time.html#Calendar%20Events)
  for valid values. Defaults to daily backups.
* `vzborg_configs`: A dict with the contents of `/etc/vzborg` despite
  the `default` config.See the
  [VzBorg documentation](https://github.com/baztian/vzborg) for a
  description of the configuration.
* `vzborg_kuma`: Optional Uptime Kuma settings. When at least one repository token is
  configured, the role installs a protected environment file and adds success and error
  notifications to each configured backup. Repository keys must use uppercase letters,
  digits, and underscores. Matchers support Bash glob patterns. Store tokens with Ansible Vault.

Example:

    vzborg_kuma:
      url: "http://192.168.178.224:3001"
      repositories:
        LOCAL:
          matcher: "/var/lib/vz/vzborg/"
          token: "{{ kuma_token_local }}"
        NAS:
          matcher: "ssh://mybackup@nas*home.borg"
          token: "{{ kuma_token_nas }}"

The role writes `/etc/vzborg/kuma.env` with mode `0600` and installs
`/usr/local/sbin/vzborg-kuma-push` with mode `0750`. Empty or omitted tokens
disable their matchers.

## Example Playbook

    - hosts: servers
      become: yes
      roles:
         - role: baztian.vzborg
      vars:
        vzborg_configs:
          local: |
            VZBORG_REPO="/var/lib/vz/vzborg/"
          nas: |
            VZBORG_REPO="ssh://{{ nas_user }}@{{ nas_hostname }}:{{ nas_ssh_port }}/./${HOSTNAME}-vzborg.borg"
            WHATEVER=123

## License

MIT
