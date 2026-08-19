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
# RPM Fusion - verified against both primaries): xpadneo, steamtinkerlaunch, NVIDIA
# low-latency Vulkan layer, localsend-bin. dkms-xpadneo is used instead of the
# akmod-xpadneo variant: its %post runs akmods, which refuses to run as root in
# container builds (builds the .ko for the installed kernels via dkms instead, and
# pulls in the xpadneo meta package itself).
dnf install -y dkms-xpadneo steamtinkerlaunch vulkan-low-latency-layer localsend-bin

# falcond (PikaOS's per-game optimization daemon, packaged by Terra): auto-detects
# games, enables performance mode while gaming, optional per-game SCX scheduler
# switching (default scx_sched=none -> doesn't touch scx_loader) + DMEM cgroup
# protection (CachyOS kernel has CONFIG_CGROUP_DMEM). Pulls falcond-profiles +
# scx-scheds automatically; Conflicts gamemode (not shipped). Service is disabled
# by default upstream (user enablement via falcond-gui) -> we enable it.
dnf install -y falcond falcond-gui
systemctl enable falcond.service

# terra-gamescope from Terra extras - explicit name so extras' priority=150 still wins over
# Fedora's gamescope (extras release package installs the repo; name match beats priority).
# --allowerasing: terra-gamescope carries a Conflicts on Fedora's gamescope, which gets
# pulled in as a dep (e.g. by mangohud/steam); Terra's build is the intended one.
dnf install -y --allowerasing terra-gamescope