# borgbackup for vzdump / proxmox ansible role

![CI](https://github.com/baztian/ansible-vzborg/workflows/CI/badge.svg)

Ansible role to install [VzBorg utility](https://github.com/baztian/vzborg) along
with some proper configuration to make sure backups are carried out on a schedule.

It carries out the backup for all configurations except `default`. Only
vms tagged with `backup` or `backup-<configname>` are backed up.

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
