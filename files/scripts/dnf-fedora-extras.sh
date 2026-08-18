#!/usr/bin/env bash
set -euo pipefail

# Fedora packages (not in Terra): terminal, fetch, zsh, gstreamer stack, thumbnailers, fonts, password manager, media/viewers
# NOTE: lollypop excluded - it hard-requires Fedora's yt-dlp which conflicts with our Terra yt-dlp-git.
dnf install -y kitty fastfetch zsh gstreamer1 gstreamer1-plugins-base gstreamer1-plugins-good gstreamer1-plugins-good-extras gstreamer1-plugins-bad-free gstreamer1-plugins-bad-free-extras gstreamer1-vaapi ffmpegthumbnailer rsms-inter-fonts adwaita-fonts-all google-noto-sans-fonts google-noto-serif-fonts google-noto-mono-fonts google-noto-color-emoji-fonts ibm-plex-fonts-all terminus-fonts open-sans-fonts google-droid-sans-fonts google-droid-serif-fonts google-droid-sans-mono-fonts dejavu-fonts-all keepassxc loupe clapper zathura zathura-pdf-poppler 'nicotine+'