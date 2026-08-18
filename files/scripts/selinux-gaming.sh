#!/usr/bin/env bash
set -euo pipefail

# SELinux adjustments for Windows/Proton/Wine gaming.
# Per openSUSE's gaming SELinux analysis (security.opensuse.org/2025/06/06/selinux-gaming.html
# and the selinux-policy-targeted-gaming package), the three booleans that matter for
# Steam/Proton/Wine on a targeted policy are execmod (textrel DLL shims - the main blocker),
# execheap (wine-preloader/Electron) and execstack (older Wine titles). All default to off.
# domain_kernel_load_modules is already ON in Fedora's targeted policy -> NVIDIA akmod/dkms
# needs no flip. selinuxuser_mmap_file does not exist in Fedora.

# Build-time `setsebool -P` writes to /var/lib/selinux which is a bootc VOLUME - it does not
# propagate on image updates. Instead, ship a oneshot unit that applies the booleans at boot
# (idempotent, guarded against a fully-disabled SELinux where there is no policy store).
cat > /usr/lib/systemd/system/selinux-gaming-booleans.service <<'EOF'
[Unit]
Description=Enable SELinux booleans for Windows/Proton/Wine gaming
After=selinux-policy.target
ConditionPathIsReadWrite=/sys/fs/selinux

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/sh -c '[ "$(getenforce)" = "Disabled" ] || setsebool -P selinuxuser_execmod 1 selinuxuser_execstack 1 selinuxuser_execheap 1'

[Install]
WantedBy=multi-user.target
EOF
ln -sf /usr/lib/systemd/system/selinux-gaming-booleans.service /etc/systemd/system/multi-user.target.wants/selinux-gaming-booleans.service