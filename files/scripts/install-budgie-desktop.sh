#!/usr/bin/env bash
set -euo pipefail

# Budgie Desktop 10.10 - Wayland-only session (labwc compositor via startbudgielabwc)
dnf install -y budgie-desktop budgie-session budgie-control-center
# labwc requires the Xwayland binary but F44's labwc rpm does not Require it (BZ 2446920);
# XWayland stays a compatibility layer - the session itself is native Wayland
dnf install -y xorg-x11-server-Xwayland
# labwc tooling: GUI config editor (Qt6), menu generator, output control
dnf install -y labwc-tweaks labwc-menu-generator wlr-randr qt6-qtwayland
# Wayland-native launcher: rofi 2.0 has the Wayland backend merged (rofi-wayland is superseded)
dnf install -y rofi
# Wayland clipboard: wl-clipboard (wl-copy/wl-paste) + cliphist (minimal on-disk history,
# no resident daemon; history persists across sessions/reboots, paired with rofi)
dnf install -y wl-clipboard cliphist