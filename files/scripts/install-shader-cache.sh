#!/usr/bin/env bash
set -euo pipefail

# System-wide shader/pipeline cache tuning for EVERY stack (NVIDIA GL+Vulkan, Mesa GL/Vulkan,
# DXVK, vkd3d-proton). All of these are enabled by default already - the real fix is raising
# NVIDIA's default 1 GiB cache cap (bytes) so large DXVK/vkd3d titles don't get pruned into
# recompile stutter loops. /etc/environment is parsed by systemd-environment-d-generator for
# both the system and user managers, so it reaches GUI sessions launched from greetd.
cat > /etc/environment <<'EOF'
__GL_SHADER_DISK_CACHE=1
__GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1
__GL_SHADER_DISK_CACHE_SIZE=10737418240
MESA_SHADER_CACHE_MAX_SIZE=4G
EOF