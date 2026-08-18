#!/usr/bin/env bash
set -euo pipefail

# scx - stable sched_ext schedulers + tools from Terra main (the nightly packages are
# gone per the stable-only decision). CO-RE BPF userspace schedulers load fine on the
# kernel-cachyos kernel (no per-kernel .ko modules since scx v1.0).
dnf install -y scx-scheds scx-tools

# scx-manager (GTK GUI on top of scx_loader) ships in the kernel-cachyos addons COPR;
# enable the repo via repofrompath only (cannot shadow Terra on upgrades)
dnf install -y --nogpgcheck --repofrompath=addons,https://download.copr.fedorainfracloud.org/results/bieszczaders/kernel-cachyos-addons/fedora-44-x86_64/ scx-manager

# scx_loader is what scx-manager toggles schedulers through - run it at boot
if systemctl list-unit-files scx_loader.service >/dev/null 2>&1; then
  systemctl enable scx_loader
fi