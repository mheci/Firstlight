#!/usr/bin/env bash
set -euo pipefail

# KDE Plasma theming + defaults. Terra (enabled in enable-terra.sh) ships all six
# requested themes as prebuilt fc44 RPMs (verified 2026-08-20 against terra44
# repodata): klassy 6.7.1 (window decorations + Plasma style), darkly 0.5.38
# (Lightly-fork Qt widget style), bibata-cursor-theme 2.0.7 (Modern/Oil/Classic),
# breeze-plus-icon-theme 6.28.0 (breeze + extra icons), fluent-kde-theme
# 20251110 (Fluent icon/style look-and-feel + -sddm subpackage). Vapor (the
# Steam Deck look) ships in COPR ublue-os/bazzite as steamdeck-kde-presets-desktop
# (fc44 chroot; ships /etc/xdg Plasma defaults drop-ins, no package conflicts on
# stock Kinoite). All prebuilt - no source builds anywhere.
dnf install -y klassy darkly bibata-cursor-theme breeze-plus-icon-theme fluent-kde-theme fluent-kde-theme-sddm

dnf install -y --nogpgcheck --repofrompath=bazzite,https://download.copr.fedorainfracloud.org/results/ublue-os/bazzite/fedora-44-x86_64 steamdeck-kde-presets-desktop

# kwin scripts are vendored into /usr/share/kwin/scripts/ (files module) - enable
# them system-wide. MUST run after the vapor install above: steamdeck-kde-presets
# ships its own /etc/xdg/kwinrc drop-in, so we merge our [Plugins] keys into it
# instead of overwriting the file (kwriteconfig6 preserves other keys).
kwriteconfig6 --file /etc/xdg/kwinrc --group Plugins --key krohnkiteEnabled true
kwriteconfig6 --file /etc/xdg/kwinrc --group Plugins --key alt-f4-desktopEnabled true

# Apply theme defaults from the ACTUAL installed theme directories (never hardcode
# a dir name we haven't verified on disk). BreezeDark always exists on Kinoite.
if [ -d /usr/share/plasma/styles/Klassy ]; then
  kwriteconfig6 --file /etc/xdg/kdeglobals --group KDE --key widgetStyle Klassy
elif [ -d /usr/share/plasma/styles/Darkly ]; then
  kwriteconfig6 --file /etc/xdg/kdeglobals --group KDE --key widgetStyle Darkly
fi
if [ -d /usr/share/kwin/decorations/org.kde.klassy ]; then
  kwriteconfig6 --file /etc/xdg/kwinrc --group org.kde.kdecoration2 --key library org.kde.klassy
fi
ICON_THEME=$(basename "$(ls -d /usr/share/icons/breeze-plus* 2>/dev/null | head -n1)" || true)
if [ -n "$ICON_THEME" ]; then
  kwriteconfig6 --file /etc/xdg/kdeglobals --group Icons --key Theme "$ICON_THEME"
fi
CURSOR_THEME=$(basename "$(ls -d /usr/share/icons/Bibata-* 2>/dev/null | head -n1)" || true)
if [ -n "$CURSOR_THEME" ]; then
  kwriteconfig6 --file /etc/xdg/kcminputrc --group Mouse --key cursorTheme "$CURSOR_THEME"
fi
kwriteconfig6 --file /etc/xdg/kdeglobals --group General --key ColorScheme BreezeDark