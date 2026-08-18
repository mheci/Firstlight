#!/usr/bin/env bash
set -euo pipefail

# Terra repo - canonical bootstrap per https://docs.terrapkg.com/usage/installing/
dnf install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release terra-gpg-keys

# Terra mesa subrepo
dnf install -y terra-release-mesa

# Prefer Terra over Fedora for all Terra-provided packages, on build and future upgrades
sed -i 's/^\[terra\(.*\)\]/[terra\1]\npriority=1/' /etc/yum.repos.d/terra.repo /etc/yum.repos.d/terra-mesa.repo