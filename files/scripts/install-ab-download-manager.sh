#!/usr/bin/env bash
set -euo pipefail

# AB Download Manager - maintained third-party COPR (anifyuliansyah), tracks upstream
# (1.10.1 for f44). Installed via --repofrompath so the COPR is never enabled globally.
dnf install -y --nogpgcheck --repofrompath=abdm,https://download.copr.fedorainfracloud.org/results/anifyuliansyah/ab-download-manager/fedora-44-x86_64/ ab-download-manager