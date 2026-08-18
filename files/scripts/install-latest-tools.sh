#!/usr/bin/env bash
set -euo pipefail

# unzip is required by the bun installer
dnf install -y unzip

# Bun - not packaged in Fedora, install system-wide via official installer.
# (opencode comes from Terra; pi's Terra RPM is broken (bogus riscv64 Requires) so it
# stays on bun - both always-latest via bun.)
export BUN_INSTALL=/usr/local
curl -fsSL https://bun.sh/install | bash

# Pi - latest via bun (Terra's pi RPM is uninstallable: garbage cross-arch Requires)
bun install -g @earendil-works/pi-coding-agent