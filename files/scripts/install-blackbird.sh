#!/usr/bin/env bash
set -euo pipefail

# blackbird - OSINT tool (search accounts by username/email across social networks).
# Pure-Python CLI, not packaged in Fedora/Terra/COPR; bake a venv into the image
# (Fedora's pip refuses system installs via PEP 668) and ship a wrapper.
# Clone pinned at commit b455050 (its requirements.txt is fully ==-pinned upstream;
# blackbird has no releases to pin a tag on).
dnf install -y python3 python3-pip python3-devel gcc git
git clone https://github.com/p1ngul1n0/blackbird /opt/blackbird
git -C /opt/blackbird checkout --detach b45505080ef51bb3ef52dc29879ee6bef31e5b94
python3 -m venv /opt/blackbird/.venv
/opt/blackbird/.venv/bin/pip install -r /opt/blackbird/requirements.txt

cat > /usr/local/bin/blackbird <<'EOF'
#!/usr/bin/env bash
exec /opt/blackbird/.venv/bin/python /opt/blackbird/blackbird.py "$@"
EOF
chmod +x /usr/local/bin/blackbird