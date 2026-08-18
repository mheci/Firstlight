#!/usr/bin/env bash
set -euo pipefail

# Terra repo - canonical bootstrap per https://docs.terrapkg.com/usage/installing/
dnf install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release terra-gpg-keys

# Terra mesa subrepo
dnf install -y terra-release-mesa

# Terra extras subrepo (conflict-heavy packages like terra-gamescope; keeps its shipped
# priority=150 so it only wins when a package name is requested explicitly)
dnf install -y --nogpgcheck --repofrompath 'terra-extras,https://repos.fyralabs.com/terra$releasever-extras' terra-release-extras

# Prefer Terra over Fedora for all Terra-provided packages, on build and future upgrades
sed -i 's/^\[terra\(.*\)\]/[terra\1]\npriority=1/' /etc/yum.repos.d/terra.repo /etc/yum.repos.d/terra-mesa.repo