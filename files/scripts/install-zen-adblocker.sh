#!/usr/bin/env bash
set -euo pipefail

# Irbis Zen - system-wide ad/tracker blocker (Wails/WebKitGTK desktop app running a local
# proxy + local root CA; HTTPS filtering CA is trusted on first run). Not in Fedora/Terra/
# Flathub; bake the tarball to /opt and ship a desktop entry (same pattern as zen-browser).
# The archive contains a single `Zen` binary; the icon is a separate asset. Needs
# webkit2gtk4.1 + gtk3, already present from the Unsloth Desktop install.
mkdir -p /opt/zen-adblocker
curl -fL -o /tmp/zen.tar.gz "https://github.com/irbis-sh/zen-desktop/releases/latest/download/Zen_linux_amd64.tar.gz"
tar -xzf /tmp/zen.tar.gz -C /opt/zen-adblocker
chmod +x /opt/zen-adblocker/Zen
ln -sf /opt/zen-adblocker/Zen /usr/local/bin/zen

mkdir -p /usr/share/icons/hicolor/scalable/apps
curl -fsSL -o /usr/share/icons/hicolor/scalable/apps/zen-adblocker.svg \
  "https://raw.githubusercontent.com/irbis-sh/zen-desktop/refs/heads/master/assets/logo.svg"

cat > /usr/share/applications/zen-adblocker.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Zen
Comment=System-wide ad-blocker and privacy guard
Exec=/usr/local/bin/zen
Icon=zen-adblocker
StartupWMClass=zen
Categories=Network;Security;Utility;
Keywords=adblock;ad-block;privacy;proxy;
EOF
rm -f /tmp/zen.tar.gz