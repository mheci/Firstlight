#!/usr/bin/env bash
set -euo pipefail

# yt-dlp (git build, conflicts with Fedora's yt-dlp) + ejs JS runtime
dnf install -y yt-dlp-git python3-yt-dlp-ejs

# Deno from Terra (main repo) - includes dx alias + completions; always latest there
dnf install -y deno

# Apps from Terra (main terra repo). NOTE: pi is NOT here - its x86_64 RPM has bogus
# cross-arch Requires (riscv64 loader) and fails to resolve; pi comes via bun instead.
dnf install -y faugus-launcher steam zed protonplus umu-launcher mission-center mpv-nightly sniffnet ghostty t3code zsh-autocomplete iosevka-nerd-fonts cachyos-ananicy-rules ananicy-cpp bpftune-nightly superfile ScopeBuddy icoextract-thumbnailer lact uupd vicinae opencode budgie-extras noctalia