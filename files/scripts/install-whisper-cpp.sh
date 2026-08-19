#!/usr/bin/env bash
set -euo pipefail

# whisper.cpp v1.9.2 - CUDA-accelerated Whisper speech transcription. No Fedora,
# RPM Fusion, or conda-forge package exists (verified), so build from source
# against the CUDA toolkit installed by the dnf module. Pinned release tarball.
dnf install -y cmake ninja-build

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

curl -fsSL -o "$TMP/whisper.tar.gz" https://github.com/ggml-org/whisper.cpp/archive/refs/tags/v1.9.2.tar.gz
tar -xzf "$TMP/whisper.tar.gz" -C "$TMP"

cmake -S "$TMP/whisper.cpp-1.9.2" -B "$TMP/build" -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DGGML_CUDA=ON
cmake --build "$TMP/build" --target whisper-cli whisper-server -j"$(nproc)"

install -Dm755 "$TMP/build/bin/whisper-cli" "$TMP/build/bin/whisper-server" /usr/local/bin/
