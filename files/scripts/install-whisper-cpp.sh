#!/usr/bin/env bash
set -euo pipefail

# whisper.cpp v1.9.2 - official PREBUILT Linux x86_64 release tarball (no source
# build): whisper-bin-ubuntu-x64.tar.gz, built on ubuntu-22.04 (glibc 2.35 ->
# runs fine on Fedora 44's glibc 2.42), containing whisper-cli, whisper-server,
# whisper-quantize, whisper-bench, libwhisper/libparakeet/libggml + the ggml CPU
# variant libs (auto-selected per CPU at runtime). NOTE: the CUDA release assets
# (whisper-cublas-*.zip) are Windows-only, verified - the only Linux CUDA path is
# the ggml-org container image, which needs nvidia-container-toolkit at runtime.
# The CPU build is the prebuilt choice per the no-source-builds policy.
# NOTE: no /usr/local/* - the base image's /usr/local is a symlink that does not
# resolve in the build container (same pitfall as the SB signer); /usr/bin and
# /usr/lib are real dirs on the default loader path.
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

curl -fL -o "$TMP/whisper.tar.gz" "https://github.com/ggml-org/whisper.cpp/releases/download/v1.9.2/whisper-bin-ubuntu-x64.tar.gz"
tar -xzf "$TMP/whisper.tar.gz" -C "$TMP"
WHISPER_DIR=$(find "$TMP" -maxdepth 2 -name whisper-cli -printf '%h\n' -quit)

install -Dm755 "$WHISPER_DIR/whisper-cli" "$WHISPER_DIR/whisper-server" "$WHISPER_DIR/whisper-quantize" "$WHISPER_DIR/whisper-bench" /usr/bin/
install -Dm755 "$WHISPER_DIR/whisper-vad-speech-segments" "$WHISPER_DIR/parakeet-cli" /usr/bin/ 2>/dev/null || true
# shared libs must land where the loader finds them (binaries are not rpath'd)
install -Dm644 "$WHISPER_DIR"/libwhisper.so* "$WHISPER_DIR"/libparakeet.so* "$WHISPER_DIR"/libggml*.so* /usr/lib/
ldconfig