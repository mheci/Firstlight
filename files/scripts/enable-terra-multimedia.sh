#!/usr/bin/env bash
set -euo pipefail

# Terra multimedia subrepo (fdk-aac for steam pipewire deps, ffmpeg, gstreamer libav plugin);
# note: terra-multimedia is marked unstable/WIP per Terra docs, but is the supported path
# for 32-bit audio codecs required by steam on Fedora 44.
dnf install -y terra-release-multimedia
# Fedora's installed libfdk-aac (1:2.0.3-2) Obsoletes fdk-aac < 1:2.0.3-2; Terra's fdk-aac is
# 0:2.0.3-1 (epoch 0) so the conflict must be resolved by erasing libfdk-aac (--allowerasing).
# Terra's fdk-aac (both arches) provides libfdk-aac.so.2 needed by steam's pipewire-libs.i686.
dnf install -y --allowerasing fdk-aac fdk-aac.i686

# ffmpeg + gstreamer libav plugin from Terra multimedia (NOT rpmfusion - Terra ffmpeg conflicts with rpmfusion's)
dnf install -y ffmpeg gstreamer1-plugin-libav