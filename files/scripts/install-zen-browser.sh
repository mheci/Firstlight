#!/usr/bin/env bash
set -euo pipefail

# Zen browser - no RPM exists (not in Terra/RPM Fusion/COPR); official tarball per https://docs.zen-browser.app/guides/install-linux
zen_tarball="https://github.com/zen-browser/desktop/releases/latest/download/zen.linux-x86_64.tar.xz"
curl -fL -o /tmp/zen.tar.xz "$zen_tarball"
mkdir -p /opt/zen-browser
tar -xJf /tmp/zen.tar.xz -C /opt/zen-browser --strip-components=1
chmod +x /opt/zen-browser/zen
ln -sf /opt/zen-browser/zen /usr/local/bin/zen
cat > /usr/share/applications/zen.desktop <<'EOF'
[Desktop Entry]
Name=Zen Browser
Comment=Experience tranquillity while browsing the web without people tracking you!
Keywords=web;browser;internet
Exec=/opt/zen-browser/zen %u
Icon=/opt/zen-browser/browser/chrome/icons/default/default128.png
Terminal=false
StartupNotify=true
StartupWMClass=zen
NoDisplay=false
Type=Application
MimeType=text/html;text/xml;application/xhtml+xml;application/vnd.mozilla.xul+xml;text/mml;x-scheme-handler/http;x-scheme-handler/https;
Categories=Network;WebBrowser;
Actions=new-window;new-blank-window;new-private-window;profile-manager-window;
[Desktop Action new-window]
Name=Open a New Window
Exec=/opt/zen-browser/zen --new-window %u
[Desktop Action new-blank-window]
Name=Open a New Blank Window
Exec=/opt/zen-browser/zen --blank-window %u
[Desktop Action new-private-window]
Name=Open a New Private Window
Exec=/opt/zen-browser/zen --private-window %u
[Desktop Action profile-manager-window]
Name=Open the Profile Manager
Exec=/opt/zen-browser/zen --ProfileManager
EOF