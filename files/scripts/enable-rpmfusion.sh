#!/usr/bin/env bash
set -euo pipefail

# RPM Fusion (fallback repos enabled; NO VLC anywhere - mpv is the media player).
# Note: rpmfusion's gstreamer1-plugins-bad-freeworld/ugly are NOT installable here - their
# x265-libs 4.1 (libx265.so.215) conflicts with Terra's x265-libs 4.2 (libx265.so.216) which
# Terra's libavcodec requires. Terra's full ffmpeg build already provides those codecs.
dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm