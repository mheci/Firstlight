#!/usr/bin/env bash
set -euo pipefail

# Full Adwaita + adw-gtk3 + icon themes. Note: F44 has no on-disk Adwaita GTK3 theme
# (it's built into GTK), and no adwaita-gtk2/adwaita-qt - Qt6 apps follow the gtk theme
# via budgie's QT_QPA_PLATFORMTHEME=gtk3.
dnf install -y adwaita-icon-theme adwaita-cursor-theme adw-gtk3-theme
# Icon themes: Papirus (+dark/light variants) from Fedora; Tela (vinceliuice) is unpackaged
# and ships no release assets - installed from the master source tarball via its install.sh
# (master tarball avoids the GitHub API entirely - no rate-limit risk).
dnf install -y papirus-icon-theme papirus-icon-theme-dark papirus-icon-theme-light

curl -fL -o /tmp/tela.tar.gz "https://github.com/vinceliuice/Tela-icon-theme/archive/refs/heads/master.tar.gz"
tar -xzf /tmp/tela.tar.gz -C /tmp
cd /tmp/Tela-icon-theme-master
bash install.sh -d /usr/share/icons

# Image-wide defaults (Budgie reads org.gnome.desktop.interface via gsettings; no locks so
# users can override). LabWC window decorations are separate (Pocillo-dark shipped by budgie).
cat > /etc/dconf/profile/user <<'EOF'
user-db:user
system-db:local
EOF

cat > /etc/dconf/db/local.d/01-theming <<'EOF'
[org/gnome/desktop/interface]
gtk-theme='adw-gtk3-dark'
icon-theme='Tela-dark'
color-scheme='prefer-dark'

[com/solus-project/budgie-panel]
dark-theme=true
EOF

dconf update