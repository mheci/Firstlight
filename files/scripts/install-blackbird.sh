#!/usr/bin/env bash
set -euo pipefail

# blackbird - OSINT tool (search accounts by username/email across social networks).
# Pure-Python CLI, not packaged in Fedora/Terra/COPR and it has no releases; bake a venv
# into the image (Fedora's pip refuses system installs via PEP 668) and ship a wrapper.
dnf install -y python3 python3-pip python3-devel gcc git
git clone --depth 1 https://github.com/p1ngul1n0/blackbird /opt/blackbird
python3 -m venv /opt/blackbird/.venv
/opt/blackbird/.venv/bin/pip install -r /opt/blackbird/requirements.txt

cat > /usr/local/bin/blackbird <<'EOF'
#!/usr/bin/env bash
exec /opt/blackbird/.venv/bin/python /opt/blackbird/blackbird.py "$@"
EOF
chmod +x /usr/local/bin/blackbird