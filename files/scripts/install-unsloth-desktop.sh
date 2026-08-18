#!/usr/bin/env bash
set -euo pipefail

# Unsloth Desktop - local LLM training/running desktop app (Tauri). No .rpm exists
# (Ubuntu .deb only, release workflow disables RPM); extract the .deb payload into the
# image rootfs. First launch provisions its own backend (pinned unsloth PyPI package +
# its own llama.cpp source build under ~/.unsloth) - needs build tools + CUDA toolkit,
# both already in the image.
dnf install -y webkit2gtk4.1 gtk3 libayatana-appindicator-gtk3 librsvg2 dpkg cmake git gcc-c++ python3

curl -fL -o /tmp/unsloth.deb \
  "https://github.com/unslothai/unsloth/releases/download/v0.1.800-beta/Unsloth-Desktop-0_1_800_beta-Ubuntu.deb"
mkdir -p /tmp/unsloth-root
dpkg-deb -x /tmp/unsloth.deb /tmp/unsloth-root
cp -a /tmp/unsloth-root/* /
rm -rf /tmp/unsloth.deb /tmp/unsloth-root