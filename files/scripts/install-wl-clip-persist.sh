#!/usr/bin/env bash
set -euo pipefail

# wl-clip-persist v0.5.0 - keeps the Wayland clipboard alive after the copying app exits.
# Not packaged in Fedora, no prebuilt binaries, not on crates.io -> build from source
# (pure-Rust wayrs-client, no wayland dev headers; Fedora rust 1.97.1 >= MSRV 1.85).
dnf install -y cargo rust
curl -fL -o /tmp/wl-clip-persist.tar.gz "https://github.com/Linus789/wl-clip-persist/archive/refs/tags/v0.5.0.tar.gz"
tar -xzf /tmp/wl-clip-persist.tar.gz -C /tmp
cd /tmp/wl-clip-persist-0.5.0
cargo build --release
install -m 0755 target/release/wl-clip-persist /usr/local/bin/wl-clip-persist
cd /
rm -rf /tmp/wl-clip-persist-0.5.0 /tmp/wl-clip-persist.tar.gz

# Autostart inside the Wayland session. --clipboard regular only (all-selections breaks GTK
# primary selection). Foreground daemon; XDG autostart backgrounds it for the session.
cat > /etc/xdg/autostart/wl-clip-persist.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=wl-clip-persist
Comment=Keep the Wayland clipboard alive after the source app exits
Exec=wl-clip-persist --clipboard regular
OnlyShowIn=Budgie;
X-GNOME-Autostart-enabled=true
NoDisplay=true
EOF