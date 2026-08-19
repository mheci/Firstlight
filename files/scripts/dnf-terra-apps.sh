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

# Stable Terra packages for the 2026-08 feature batch (none exist in Fedora 44 or
# RPM Fusion - verified against both primaries): xpadneo (dkms build for both
# kernels), steamtinkerlaunch, NVIDIA low-latency Vulkan layer, localsend-bin.
dnf install -y xpadneo steamtinkerlaunch vulkan-low-latency-layer localsend-bin

# terra-gamescope from Terra extras - explicit name so extras' priority=150 still wins over
# Fedora's gamescope (extras release package installs the repo; name match beats priority).
# --allowerasing: terra-gamescope carries a Conflicts on Fedora's gamescope, which gets
# pulled in as a dep (e.g. by mangohud/steam); Terra's build is the intended one.
dnf install -y --allowerasing terra-gamescope