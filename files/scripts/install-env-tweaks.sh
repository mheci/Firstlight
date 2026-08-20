#!/usr/bin/env bash
set -euo pipefail

# System-wide NVIDIA/GL/Qt cache + GLX env. /etc/environment is parsed by
# systemd-environment-d-generator for both the system and user managers, so it
# reaches GUI sessions launched from SDDM.
#
# __GL_SHADER_DISK_CACHE: NVIDIA's shader cache is enabled by default for direct
# rendering - the real fix is raising the 1 GiB default cap (bytes) so large
# DXVK/vkd3d titles don't get pruned into recompile stutter loops, plus
# SKIP_CLEANUP to stop background cache eviction churn.
# MESA_SHADER_CACHE_MAX_SIZE: same idea for the Mesa cache.
# __GLX_VENDOR_LIBRARY_NAME=nvidia: forces GLVND to load the NVIDIA GLX driver
# (needed by some hybrid setups; harmless on single-GPU).
# Qt 6 Quick/QML ships an on-by-default shader disk cache (QSG_RHI_PIPELINE_CACHE_SAVE);
# nothing to enable there - we just don't disable it.
cat > /etc/environment <<'EOF'
__GL_SHADER_DISK_CACHE=1
__GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1
__GL_SHADER_DISK_CACHE_SIZE=10737418240
MESA_SHADER_CACHE_MAX_SIZE=4G
__GLX_VENDOR_LIBRARY_NAME=nvidia
EOF