#!/usr/bin/env bash
set -euo pipefail

# greetd - lightweight login manager (service aliases display-manager.service)
dnf install -y greetd greetd-selinux
# GUI greeter: gtkgreet under cage (wlroots kiosk compositor)
dnf install -y gtkgreet cage

# Modern multi-head greeter setup: cage -m extend covers ALL connected monitors (hotplug-aware,
# single virtual output across every display); -s enables VT switching; -d drops decorations.
# NVIDIA: WLR_RENDERER=vulkan avoids flicker on the proprietary driver,
# WLR_NO_HARDWARE_CURSORS=1 sidesteps cursor rendering issues on wlroots.
cat > /etc/greetd/config.toml <<'EOF'
[terminal]
vt = 1

[default_session]
command = "env WLR_RENDERER=vulkan WLR_NO_HARDWARE_CURSORS=1 dbus-run-session cage -s -m extend -d -- gtkgreet"
user = "greetd"
EOF

systemctl enable greetd.service