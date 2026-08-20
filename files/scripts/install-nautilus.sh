#!/usr/bin/env bash
set -euo pipefail

# File manager + disk utility (GTK, no GNOME-shell deps) with a minimal gvfs set:
# base (trash/udisks via hard deps) + MTP + gphoto2 only. install_weak_deps=False is set
# globally in /etc/dnf/dnf.conf and keeps out nautilus's recommended gvfs-fuse/thumbnailers.
dnf install -y nautilus gvfs gvfs-mtp gvfs-gphoto2 gnome-disk-utility