#!/usr/bin/env bash
set -euo pipefail

# CachyOS-Settings - tuned sysctl/udev/systemd tweaks + helper scripts.
# Installed from the bieszczaders/kernel-cachyos-addons COPR via --repofrompath (no global
# repo enable, so it cannot shadow Terra packages on future upgrades). It Conflicts with and
# Provides zram-generator-defaults, so Fedora's zram-generator-defaults is auto-removed.
# power-profiles-daemon is needed by the game-performance wrapper (install-game-performance.sh).
dnf install -y --allowerasing --nogpgcheck --repofrompath=addons,https://download.copr.fedorainfracloud.org/results/bieszczaders/kernel-cachyos-addons/fedora-44-x86_64/ cachyos-settings power-profiles-daemon

# User prefers zswap over zram: disable zram so cachyos-settings' 30-zram.rules (which would
# disable zswap and raise swappiness to 150 the moment a zram0 device appears) never fires.
# An empty /etc/systemd/zram-generator.conf disables the generator; mask the setup unit too.
rm -f /usr/lib/systemd/zram-generator.conf
touch /etc/systemd/zram-generator.conf
systemctl mask systemd-zram-setup@zram0.service