#!/usr/bin/env bash
set -euo pipefail

# Minimal Plasma: strip stock Kinoite bloat that has no place on a focused
# gaming/creative desktop. Removal MUST use tsflags=noscripts: these packages'
# %preun/%postun scriptlets call systemctl to disable units (e.g. akonadi's
# akonadi_control.service), which fails hard inside the build container (no
# running systemd) and aborts the whole dnf transaction. With scripts skipped
# the packages are simply removed - nothing here needs a running daemon.
# auto-remove stays off (dnf's default for `remove` is to cascade) so we never
# silently drop something a wanted package depends on.
dnf remove -y --setopt=tsflags=noscripts \
  akonadi-server akonadi-server-mysql \
  audiocd-kio filelight kcharselect kde-connect kde-partitionmanager \
  kdenetwork-filesharing kfind khelpcenter kio-gdrive kjournald kmenuedit \
  krdp krfb kwalletmanager5 kwrite plasma-disks plasma-drkonqi \
  plasma-thunderbolt plasma-vault plasma-welcome samba-usershares thermald \
  kamera kaccounts-integration-qt6 kaccounts-providers kdebugsettings kdnssd \
  kunifiedpush plasma-setup plasma-desktop-doc \
  fcitx5 fcitx5-configtool fcitx5-gtk fcitx5-qt kcm-fcitx5