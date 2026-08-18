#!/usr/bin/env bash
set -euo pipefail

# greenboot (Rust rewrite, fedora-iot/greenboot-rs) - boot health checks + automatic
# rollback. Runs required.d/wanted.d checks before boot-complete.target; if a check
# fails it reboots, and after GREENBOOT_MAX_BOOT_ATTEMPTS (default 3) failed boots it
# rolls back to the previous deployment. This is what turns a bad kernel update into a
# clean fallback - alongside the stock Fedora kernel kept as the signed boot fallback.
# The default-health-checks subpackage ships the required.d DNS + watchdog checks and a
# drop-in ordering greenboot-healthcheck.service After=network-online.target, so checks
# never race Wi-Fi bring-up.
dnf install -y greenboot greenboot-default-health-checks

systemctl enable greenboot-healthcheck.service