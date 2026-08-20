#!/usr/bin/env bash
set -euo pipefail

# FlameGet - GTK4 download manager (aria2/curl/yt-dlp frontend). No Fedora/Terra package
# and no native rpm - run from a source checkout in /opt with a venv (native, no Flatpak).
# yt-dlp must be importable as the python `yt_dlp` module (Terra's yt-dlp-git on PATH is
# not enough), so it's pip-installed into the venv.
dnf install -y aria2 gtk4 graphene libappindicator-gtk3 python3-gobject python3-pycurl \
  python3-flask python3-requests python3-waitress python3-certifi python3-psutil \
  python3-loguru python3-platformdirs python3-websocket-client xdg-user-dirs ffmpeg

git clone --depth 1 https://github.com/C-Yassin/FlameGet.git /opt/flameget
python3 -m venv --system-site-packages /opt/flameget/venv
# Pinned pip + venv deps (scorecard Pinned-Dependencies; versions verified on PyPI 2026-08-19)
/opt/flameget/venv/bin/pip install pip==26.2.1
/opt/flameget/venv/bin/pip install aria2p==0.12.1 yt-dlp==2026.08.19 yt-dlp-get-pot-rustypipe==0.2.0

# rustypipe-botguard (YouTube POT binary; otherwise a first-run dialog downloads it).
# Best-effort: the tarball layout varies, so locate the binary rather than assume.
mkdir -p /opt/flameget/binaries
curl -fL -o /tmp/rp.tar.xz \
  "https://codeberg.org/ThetaDev/rustypipe-botguard/releases/download/v0.1.2/rustypipe-botguard-v0.1.2-x86_64-unknown-linux-gnu.tar.xz"
tar xf /tmp/rp.tar.xz -C /opt/flameget/binaries/ 2>/dev/null || true
rp_bin=$(find /opt/flameget/binaries -name rustypipe-botguard -type f | head -n1)
if [ -n "$rp_bin" ]; then chmod +x "$rp_bin"; fi
rm -f /tmp/rp.tar.xz

cat > /usr/local/bin/flameget <<'EOF'
#!/bin/sh
exec /opt/flameget/venv/bin/python /opt/flameget/main.py "$@"
EOF
chmod +x /usr/local/bin/flameget

cat > /usr/share/applications/flameget.desktop <<'EOF'
[Desktop Entry]
Name=FlameGet
Comment=Advanced Download Manager
Exec=/usr/local/bin/flameget %u
Icon=flameget
Terminal=false
Type=Application
Categories=Download Manager
StartupNotify=true
MimeType=x-scheme-handler/magnet;x-scheme-handler/flameget;
Keywords=Network;FileTransfer
EOF
if [ -f /opt/flameget/repo-data/flameget.svg ]; then
  mkdir -p /usr/share/icons/hicolor/scalable/apps
  cp /opt/flameget/repo-data/flameget.svg /usr/share/icons/hicolor/scalable/apps/flameget.svg
fi