#!/usr/bin/env bash
set -euo pipefail

# UpScaly v2.15.0 - AI image upscaler (Real-ESRGAN via ncnn-vulkan). No rpm for
# the Linux app; the project ships AppImage only. Install by extracting the
# AppImage's squashfs with unsquashfs (no FUSE needed at build time), verified
# against the sha512 from the release's latest-linux.yml.
VER=2.15.0
URL="https://github.com/upscayl/upscayl/releases/download/v${VER}/upscayl-${VER}-linux.AppImage"
SHA512="5d3d60bf1e249762558f0895211193e7c3d3019c185250f5a004f637abc012211155d36b7dbaff87367de04a9a1132f7d93de9f14e843291a95c6a0692815562"

dnf install -y squashfs-tools

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

curl -fsSL -o "$TMP/upscayl.AppImage" "$URL"
echo "$SHA512  $TMP/upscayl.AppImage" | sha512sum -c -

unsquashfs -d "$TMP/squashfs-root" "$TMP/upscayl.AppImage" >/dev/null

DESKTOP=$(find "$TMP/squashfs-root" -maxdepth 2 -name '*.desktop' | head -n1)
ICON=$(find "$TMP/squashfs-root" -maxdepth 4 -name 'upscayl*' \( -name '*.png' -o -name '*.svg' \) | grep -v 'resources/' | head -n1)

mkdir -p /opt/upscayl
cp -a "$TMP/squashfs-root/." /opt/upscayl/
chmod -R a+rX /opt/upscayl

ln -sf /opt/upscayl/AppRun /usr/local/bin/upscayl

if [ -n "$DESKTOP" ]; then
  install -Dm644 "$DESKTOP" /usr/share/applications/upscayl.desktop
  sed -i 's|^Exec=.*|Exec=/usr/local/bin/upscayl %U|' /usr/share/applications/upscayl.desktop
  if [ -n "$ICON" ]; then
    install -Dm644 "$ICON" /usr/share/icons/hicolor/256x256/apps/upscayl.png
    sed -i 's|^Icon=.*|Icon=upscayl|' /usr/share/applications/upscayl.desktop
  fi
fi
