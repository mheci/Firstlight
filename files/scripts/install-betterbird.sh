#!/usr/bin/env bash
set -euo pipefail

# Betterbird - Thunderbird fork (email client). No Fedora/Terra package; native tarball
# to /opt (no Flatpak), matching the project's own install-on-linux script.
dnf install -y gtk3 libXt dbus-glib libnotify alsa-lib

curl -fL -o /tmp/betterbird.tar.xz \
  "https://www.betterbird.eu/downloads/LinuxArchive/betterbird-140.13.0esr-bb25.en-US.linux-x86_64.tar.xz"
echo "d346c0c6c4f8dcde204f97f2d780d685530b9163d864bccd5c149456394ba1c0  /tmp/betterbird.tar.xz" | sha256sum -c -
tar xf /tmp/betterbird.tar.xz -C /opt
ln -s /opt/betterbird/betterbird /usr/local/bin/betterbird
rm -f /tmp/betterbird.tar.xz

cat > /usr/share/applications/eu.betterbird.Betterbird.desktop <<'EOF'
[Desktop Entry]
Name=Betterbird
Comment=Betterbird Email Client
Exec=/opt/betterbird/betterbird %u
Icon=/opt/betterbird/chrome/icons/default/default256.png
Terminal=false
Type=Application
MimeType=message/rfc822;x-scheme-handler/mailto;application/x-xpinstall;application/x-extension-ics;text/calendar;text/vcard;text/x-vcard;x-scheme-handler/webcal;x-scheme-handler/webcals;x-scheme-handler/mid;
Categories=Network;Email;
StartupNotify=true
StartupWMClass=eu.betterbird.Betterbird
Actions=ComposeMessage;OpenAddressBook;
EOF