#!/usr/bin/env bash
set -euo pipefail

# game-performance: per-launch performance power profile + scx_loader Gaming
# mode (CachyOS concept; scxctl ships with scx-tools). Also enable the PCI
# latency timer service (sound card glitch-free audio, CachyOS).
install -Dm755 /dev/stdin /usr/bin/game-performance <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

# CachyOS game-performance port: runs a command with the performance power
# profile (restored on exit, screensaver inhibited) and switches scx_loader to
# its Gaming mode for the duration (also restored). Uses scxctl from scx-tools.

switch_scx() {
  if command -v scxctl &>/dev/null && scxctl get >/dev/null 2>&1; then
    scxctl switch -m "$1" >/dev/null 2>&1 || true
  fi
}

if ! command -v powerprofilesctl &>/dev/null; then
  echo "Error: powerprofilesctl not found" >&2
  exit 1
fi

if ! powerprofilesctl list | grep -q 'performance:'; then
  exec "$@"
fi

switch_scx gaming
trap 'switch_scx auto' EXIT

if [ -n "${GAME_PERFORMANCE_SCREENSAVER_ON:-}" ]; then
  powerprofilesctl launch -p performance \
    -r "Launched with game-performance utility" -- "$@"
else
  systemd-inhibit --why "game-performance is running" powerprofilesctl launch \
    -p performance -r "Launched with game-performance utility" -- "$@"
fi
EOF

# Sound-card PCI latency timers -> 80 cycles (glitch-free audio)
systemctl enable pci-latency.service
