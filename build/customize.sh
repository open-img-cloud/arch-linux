#!/usr/bin/env bash
# Customize hook called by the build-libguestfs-image reusable workflow.
# Receives the qcow2 path as $1.
#
# The upstream Arch Linux cloudimg (arch-boxes) already ships cloud-init
# (with cloud-guest-utils for growpart), openssh, sudo, a serial console
# (console=ttyS0,115200), systemd-networkd/resolved and the `arch` default
# user (wheel, passwordless sudo). It also ships qemu-guest-agent, started
# by its udev rule when the virtio-serial channel exists, so there is
# nothing to enable. The org-wide cloud-init policy drop-in
# (datasource_list, disable_root, ssh_pwauth=false, mount_default_fields)
# is injected by the reusable workflow after this script runs.
#
# Fallback: should a future upstream build drop qemu-guest-agent, it is
# installed from the official repositories. The image ships no pacman
# keyring (pacman-init.service creates one at first boot), so a temporary
# keyring is created for the install and removed afterwards, so that every
# instance still generates its own keyring. The package cache is emptied;
# the sync databases are kept, as upstream ships them.

set -euo pipefail

QCOW2="${1:?usage: customize.sh <path-to-qcow2>}"

if [[ ! -f "$QCOW2" ]]; then
  echo "::error::qcow2 not found: $QCOW2" >&2
  exit 1
fi

echo "[customize] target: $QCOW2"

virt-customize -a "$QCOW2" \
  --run-command 'if [ ! -x /usr/bin/qemu-ga ]; then
      set -e
      pacman-key --init
      pacman-key --populate archlinux
      pacman -Sy --noconfirm --needed qemu-guest-agent
      rm -rf /etc/pacman.d/gnupg
    fi' \
  --run-command 'test -x /usr/bin/qemu-ga && test -f /usr/lib/udev/rules.d/99-qemu-guest-agent.rules' \
  --run-command 'rm -rf /var/cache/pacman/pkg/* /tmp/* /var/tmp/*'

echo "[customize] done"
