#!/usr/bin/env bash
set -euo pipefail

# Fedora packages (not in Terra): terminal, fetch, zsh, gstreamer stack, thumbnailers, fonts, password manager, media/viewers
# yt-dlp + mpv: stable replacements for the dropped Terra nightlies (yt-dlp-git, mpv-nightly).
# lollypop: previously excluded because it hard-requires Fedora's yt-dlp, which conflicted
# with Terra's yt-dlp-git - the conflict is gone with stable yt-dlp, so it's back.
dnf install -y kitty fastfetch zsh gstreamer1 gstreamer1-plugins-base gstreamer1-plugins-good gstreamer1-plugins-good-extras gstreamer1-plugins-bad-free gstreamer1-plugins-bad-free-extras gstreamer1-vaapi ffmpegthumbnailer rsms-inter-fonts adwaita-fonts-all google-noto-sans-fonts google-noto-serif-fonts google-noto-mono-fonts google-noto-color-emoji-fonts ibm-plex-fonts-all terminus-fonts open-sans-fonts google-droid-sans-fonts google-droid-serif-fonts google-droid-sans-mono-fonts dejavu-fonts-all keepassxc loupe clapper zathura zathura-pdf-poppler 'nicotine+' yt-dlp mpv lollypop

# Rust CLI utils (prebuilt Fedora packages, preferred over C/unsafe equivalents):
# ripgrep (grep), fd-find (find), bat (cat), eza (ls), zoxide (cd), du-dust (du),
# procs (ps). Verified present in Fedora 44 base/updates 2026-08-20.
dnf install -y ripgrep fd-find bat eza zoxide du-dust procs
# disk utility GUI (Dolphin + KDE Partition Manager cover the rest)
dnf install -y gnome-disk-utility
# wl-clipboard: wl-copy/wl-paste (Wayland clipboard CLI; wl-clip-persist's runtime pairing)
dnf install -y wl-clipboard

# perf/features (2026-08 batch): input remapping, display control, low-latency graphics,
# AI/creative tooling (darktable/blender/kdenlive/easyeffects), gaming (lutris, protontricks),
# sync/network apps, OBS Studio (obs-studio is now in Fedora 44; the distroav plugin comes
# from RPM Fusion nonfree). Not in Fedora/Terra/RPM Fusion (verified): protonup-qt,
# steamtinkerlaunch (Terra instead), nvidia-container-toolkit (dropped - no GPU containers).
# fstrim is part of systemd, not a package (install_weak_deps=False ships a dnf.conf override).
dnf install -y input-remapper ddcutil i2c-tools vulkan-loader \
  syncthing tailscale rclone borgmatic distrobox easyeffects darktable blender kdenlive \
  lutris protontricks obs-studio obs-studio-plugin-distroav

# daemons that belong on at boot
systemctl enable input-remapper tailscaled