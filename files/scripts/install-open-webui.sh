#!/usr/bin/env bash
set -euo pipefail

# Open WebUI as the UI for our CUDA llama.cpp (llama-server). Open WebUI is a pure HTTP
# client over llama-server's OpenAI-compatible API - it holds no models itself.
# Installed as a pinned quadlet container (docs-recommended path): a pip install would drag
# in multi-GB torch and Python 3.11/3.12 on top of F44's 3.13.
# Network=host so the container reaches llama-server on 127.0.0.1; llama-server should run
# with --port 10000 (not the WebUI's 8080). Connect in the UI:
#   Admin Settings -> Connections -> OpenAI -> URL http://127.0.0.1:10000/v1 -> Provider: llama.cpp
dnf install -y podman

cat > /etc/containers/systemd/open-webui.container <<'EOF'
[Unit]
Description=Open WebUI container (llama.cpp frontend)
After=network-online.target

[Container]
Image=ghcr.io/open-webui/open-webui:v0.11.0
ContainerName=open-webui
Network=host
Volume=open-webui:/app/backend/data
Environment=AIOHTTP_CLIENT_TIMEOUT_MODEL_LIST=30

[Service]
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable without a running systemd (container build): the systemd-podman generator at boot
# produces open-webui.service from the .container file; the enable symlink mirrors what
# `systemctl enable` would create offline (open-webui.service -> the .container file).
mkdir -p /etc/systemd/system/multi-user.target.wants
ln -sf /etc/containers/systemd/open-webui.container /etc/systemd/system/multi-user.target.wants/open-webui.service