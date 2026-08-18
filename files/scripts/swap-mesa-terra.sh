#!/usr/bin/env bash
set -euo pipefail

# Mesa from Terra. Installed mesa in the base is 0:26.1.6-3.fc44 (epoch 0); Fedora moved mesa
# to epoch 1 (1:26.1.6-3), Terra rebuilds with epoch 0 (up to 0:26.1.6-1). dnf reinstall needs the
# exact same NEVRA in a repo, which no longer exists -> use downgrade with Fedora repos disabled
# so Terra's mesa build is the only candidate (guarantees Terra provenance).
dnf downgrade -y --disablerepo=fedora --disablerepo=updates mesa-dri-drivers mesa-vulkan-drivers mesa-libGL mesa-libEGL mesa-libgbm