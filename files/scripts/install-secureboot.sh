#!/usr/bin/env bash
set -euo pipefail

# Machine-local Secure Boot setup (replaces the old build-time MOK signing):
# the image never carries a private key. On each machine, firstlight-sb-sign
# generates a key in /var/lib/firstlight-mok, signs the CachyOS kernels + modules
# of every deployment, and queues a one-time MOK enrollment (reboot to complete).
# Runs automatically at boot (firstlight-sb-sign.service) and on demand via
# `just sb-setup`. See AGENTS.md "kernel-cachyos + Secure Boot" for the design.
dnf install -y sbsigntools zstd mokutil

# enable without a running systemd (container build) - direct symlink, equivalent
# to `systemctl enable firstlight-sb-sign.service`.
ln -sf /usr/lib/systemd/system/firstlight-sb-sign.service \
  /etc/systemd/system/multi-user.target.wants/firstlight-sb-sign.service