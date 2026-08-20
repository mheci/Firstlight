#!/usr/bin/env bash
set -euo pipefail

# Glance - self-hosted dashboard (RSS/feeds aggregator). Not in Fedora/Terra repos; official
# static Go binary from GitHub releases (README's manual-binary-install pattern).
# Pinned to v0.8.5 (checksum-free release asset); direct tag URL - no GitHub API (no rate limits).
mkdir -p /opt/glance
curl -fL -o /tmp/glance.tar.gz "https://github.com/glanceapp/glance/releases/download/v0.8.5/glance-linux-amd64.tar.gz"
tar -xzf /tmp/glance.tar.gz -C /opt/glance
ln -sf /opt/glance/glance /usr/local/bin/glance

# Config: glance defaults to glance.yml in CWD, so --config is explicit. Port 8081 to avoid
# clashing with Open WebUI (8080). Listens on localhost only (personal desktop dashboard).
cat > /etc/glance.yml <<'EOF'
server:
  host: localhost
  port: 8081
pages:
  - name: Home
    columns:
      - size: full
        widgets:
          - type: hacker-news
          - type: rss
            feeds:
              - url: https://selfh.st/rss/
EOF

cat > /usr/lib/systemd/system/glance.service <<'EOF'
[Unit]
Description=Glance dashboard
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/glance --config /etc/glance.yml
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Enable without a running systemd (container build) - direct symlink, equivalent to
# `systemctl enable glance.service`.
ln -sf /usr/lib/systemd/system/glance.service /etc/systemd/system/multi-user.target.wants/glance.service