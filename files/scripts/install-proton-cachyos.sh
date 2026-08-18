#!/usr/bin/env bash
set -euo pipefail

# Proton-CachyOS - CachyOS's Proton fork (Steam compatibility tool, Steam Linux Runtime builds).
# No Fedora/Terra packaging; Steam only scans the per-user ~/.steam/root/compatibilitytools.d/,
# so the release tarball is baked into the image and a per-user installer extracts it after
# login. Then restart Steam and force it per-game: Properties -> Compatibility.
mkdir -p /usr/share/proton-cachyos
curl -fL -o /usr/share/proton-cachyos/proton-cachyos-11.0-20260703-slr-x86_64.tar.xz \
  "https://github.com/CachyOS/proton-cachyos/releases/download/cachyos-11.0-20260703-slr/proton-cachyos-11.0-20260703-slr-x86_64.tar.xz"

cat > /usr/local/bin/proton-cachyos-install <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
mkdir -p "$HOME/.steam/root/compatibilitytools.d"
tar -xf /usr/share/proton-cachyos/proton-cachyos-11.0-20260703-slr-x86_64.tar.xz \
  -C "$HOME/.steam/root/compatibilitytools.d/"
echo "Proton-CachyOS installed. Restart Steam, then enable it per game:"
echo "Properties -> Compatibility -> Force the use of a specific Steam Play compatibility tool"
EOF
chmod +x /usr/local/bin/proton-cachyos-install