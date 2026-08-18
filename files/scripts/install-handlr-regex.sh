#!/usr/bin/env bash
set -euo pipefail

# handlr-regex - fast default-application handler (Rust, fork of handlr with regex).
# Not in Fedora/Terra; install the official release binary (x86_64 glibc, stripped).
curl -fL -o /tmp/handlr "https://github.com/Anomalocaridid/handlr-regex/releases/download/v0.13.0/handlr"
install -m 0755 /tmp/handlr /usr/local/bin/handlr
rm -f /tmp/handlr