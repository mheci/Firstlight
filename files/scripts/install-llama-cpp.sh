#!/usr/bin/env bash
set -euo pipefail

# llama.cpp with CUDA backend - prebuilt conda-forge binaries (official per llama.cpp docs/install.md).
# Why not source build: official Linux release binaries are CPU-only, Fedora's llama-cpp is
# ROCm-only and stale, Terra has none. conda-forge ships current CUDA builds (cuda129/cuda130),
# self-contained (no /usr/local/cuda needed at runtime).

# micromamba - tiny static conda-compatible package manager
curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj -C /tmp bin/micromamba
install -Dm755 /tmp/bin/micromamba /usr/local/bin/micromamba
rm -rf /tmp/bin

# CUDA-enabled llama.cpp into a dedicated env (pinned to the cuda130 variant)
micromamba create -y -p /opt/llama -c conda-forge "llama.cpp=*=cuda130*"

# Link the llama tools into the system PATH
for f in /opt/llama/bin/llama-*; do
  ln -sf "$f" "/usr/local/bin/$(basename "$f")"
done

# Slim down the package cache
rm -rf /root/.cache/micromamba

# Model storage (default for a system service / router)
mkdir -p /var/lib/llama/models