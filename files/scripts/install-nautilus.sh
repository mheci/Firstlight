#!/usr/bin/env bash
set -euo pipefail

# File manager + disk utility (GTK, no GNOME-shell deps) with a minimal gvfs set:
# base (trash/udisks via hard deps) + MTP + gphoto2 only. install_weak_deps=False keeps out
# nautilus's recommended gvfs-fuse/thumbnailers and udisks2's recommended filesystem tools.
dnf install -y --setopt=install_weak_deps=False nautilus gvfs gvfs-mtp gvfs-gphoto2 gnome-disk-utility