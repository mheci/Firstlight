#!/usr/bin/env bash
set -euo pipefail

# NTSync: the kernel creates /dev/ntsync with mode 0666 (world rw) the moment the module
# loads - no udev rule needed (confirmed in drivers/misc/ntsync.c; Arch wiki agrees).
# SELinux: no ntsync type exists; unconfined_t and wine_t can open+ioctl it with no AVC.
# All that's needed is autoloading the module so the device exists for every user/app.
echo 'ntsync' > /usr/lib/modules-load.d/ntsync.conf