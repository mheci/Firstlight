#!/usr/bin/env bash
set -euo pipefail

# unzip is required by the bun installer
dnf install -y unzip

# Bun - not packaged in Fedora. Pinned release binary (bun-v1.3.14, official GitHub
# release asset; no checksums published by upstream) installed to /usr/local/bin.
# (opencode comes from Terra; pi's Terra RPM is broken (bogus riscv64 Requires) so it
# stays on bun - pi itself always-latest via bun, per user decision.)
# NOTE: the release zip's layout differs across versions (bun at the zip root vs
# bun-linux-x64/bun) - extract to a scratch dir and locate the binary, don't assume.
curl -fL -o /tmp/bun.zip "https://github.com/oven-sh/bun/releases/download/bun-v1.3.14/bun-linux-x64.zip"
mkdir -p /tmp/bun-extract
unzip -o /tmp/bun.zip -d /tmp/bun-extract
install -m 0755 "$(find /tmp/bun-extract -type f -name bun | head -n1)" /usr/local/bin/bun
rm -rf /tmp/bun.zip /tmp/bun-extract

# Pi - latest via bun (Terra's pi RPM is uninstallable: garbage cross-arch Requires)
bun install -g @earendil-works/pi-coding-agent