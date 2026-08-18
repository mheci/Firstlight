#!/usr/bin/env bash
set -euo pipefail

# Hermes Agent (Nous Research) - autonomous AI agent CLI (TUI + gateway).
# Running as root -> FHS layout: code /usr/local/lib/hermes-agent, command
# /usr/local/bin/hermes, data /root/.hermes (persists via /var/roothome on bootc).
# Interactive setup (provider/API keys) is per-user at first run; browser/computer-use
# toolchains are skipped at build (add on demand via `hermes`) to keep the image lean.
# It can be pointed at our llama-server (Custom endpoint -> http://localhost:10000/v1,
# needs llama-server --jinja --ctx-size 64000 for tool calling).
curl -fsSL https://hermes-agent.nousresearch.com/install.sh |
  bash -s -- --skip-setup --skip-browser --skip-computer-use --non-interactive