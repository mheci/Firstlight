#!/usr/bin/env bash
set -euo pipefail

# Waterfox - official BrowserWorks OBS repo (announced with 6.7.0-beta.3);
# https://www.waterfox.com/download/ - RPM+DEB repos for Fedora/Ubuntu/Mageia
cat > /etc/yum.repos.d/waterfox.repo <<'EOF'
[isv:BrowserWorks]
name=Waterfox (Fedora_44)
type=rpm-md
baseurl=https://download.opensuse.org/repositories/isv:/BrowserWorks/Fedora_44/
gpgcheck=1
gpgkey=https://download.opensuse.org/repositories/isv:/BrowserWorks/Fedora_44/repodata/repomd.xml.key
enabled=1
EOF
dnf install -y waterfox