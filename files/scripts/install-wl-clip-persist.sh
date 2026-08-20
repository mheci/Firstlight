#!/usr/bin/env bash
set -euo pipefail

# wl-clip-persist - keeps the Wayland clipboard alive after the copying app exits.
# No Fedora/Terra/RPM-Fusion package, no GitHub prebuilt binaries (source-only
# releases, verified 2026-08-20) -> install the prebuilt RPM from the dedicated
# leloubil COPR (v0.4.1, fedora-44 chroot). No source build per policy.
dnf install -y --repofrompath 'wlcpp,https://download.copr.fedorainfracloud.org/results/leloubil/wl-clip-persist/fedora-44-x86_64' \
  --setopt='wlcpp.gpgcheck=1,wlcpp.gpgkey=https://download.copr.fedorainfracloud.org/results/leloubil/wl-clip-persist/pubkey.gpg' \
  wl-clip-persist

# Autostart inside the Wayland session. --clipboard regular only (all-selections breaks GTK
# primary selection). Foreground daemon; XDG autostart backgrounds it for the session.
cat > /etc/xdg/autostart/wl-clip-persist.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=wl-clip-persist
Comment=Keep the Wayland clipboard alive after the source app exits
Exec=wl-clip-persist --clipboard regular
OnlyShowIn=KDE;
X-GNOME-Autostart-enabled=true
NoDisplay=true
EOF