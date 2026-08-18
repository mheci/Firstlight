#!/usr/bin/env bash
set -euo pipefail

# Midori browser - Firefox fork (goastian/midori-desktop). Not in Fedora/Terra/Flathub.
# The project's Fedora RPM depends on bundled Mozilla libs not in Fedora (libmozgtk.so etc),
# so install natively from the AppImage by extracting it (--appimage-extract needs no FUSE)
# to /opt/midori - self-contained, system-wide.
curl -fL -o /tmp/midori.AppImage \
  "https://github.com/goastian/midori-desktop/releases/download/v11.9.1/Midori-11.9.1-x86_64.AppImage"
chmod +x /tmp/midori.AppImage
cd /tmp
./midori.AppImage --appimage-extract >/dev/null
mv /tmp/squashfs-root /opt/midori
ln -sf /opt/midori/AppRun /usr/local/bin/midori
if [ -f /opt/midori/.DirIcon ]; then
  mkdir -p /usr/share/icons/hicolor/scalable/apps
  cp /opt/midori/.DirIcon /usr/share/icons/hicolor/scalable/apps/midori.png
fi
cat > /usr/share/applications/midori.desktop <<'EOF'
[Desktop Entry]
Name=Midori
Comment=Fast and lightweight web browser
Exec=/usr/local/bin/midori %u
Icon=midori
Terminal=false
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
EOF
rm -f /tmp/midori.AppImage