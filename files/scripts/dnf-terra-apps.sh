#!/usr/bin/env bash
set -euo pipefail

# ejs JS runtime
dnf install -y python3-yt-dlp-ejs

# Deno from Terra (main repo) - includes dx alias + completions; always latest there
dnf install -y deno

# Apps from Terra (main terra repo). NOTE: pi is NOT here - its x86_64 RPM has bogus
# cross-arch Requires (riscv64 loader) and fails to resolve; pi comes via bun instead.
# yt-dlp/mpv/bpftune were nightly (yt-dlp-git, mpv-nightly, bpftune-nightly); per user
# decision all nightlies are now stable: yt-dlp + mpv from Fedora (dnf-fedora-extras),
# bpftune dropped (no stable package exists in Fedora or Terra).
dnf install -y faugus-launcher steam zed protonplus umu-launcher mission-center sniffnet ghostty t3code zsh-autocomplete iosevka-nerd-fonts cachyos-ananicy-rules ananicy-cpp superfile ScopeBuddy icoextract-thumbnailer lact uupd vicinae opencode budgie-extras noctalia

# terra-gamescope from Terra extras - explicit name so extras' priority=150 still wins over
# Fedora's gamescope (extras release package installs the repo; name match beats priority)
dnf install -y terra-gamescope