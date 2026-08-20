#!/usr/bin/env bash
set -euo pipefail

# unzip is required by the bun installer
dnf install -y unzip

# Bun - not packaged in Fedora. Pinned release binary (bun-v1.3.14, official GitHub
# release asset; no checksums published by upstream) installed to /usr/local/bin.
# (opencode comes from Terra; pi's Terra RPM is broken (bogus riscv64 Requires) so it
# stays on bun - pi itself always-latest via bun, per user decision.)
curl -fL -o /tmp/bun.zip "https://github.com/oven-sh/bun/releases/download/bun-v1.3.14/bun-linux-x64.zip"
unzip -o /tmp/bun.zip -d /usr/local/bin
chmod +x /usr/local/bin/bun
rm -f /tmp/bun.zip

# Pi - latest via bun (Terra's pi RPM is uninstallable: garbage cross-arch Requires)
bun install -g @earendil-works/pi-coding-agent