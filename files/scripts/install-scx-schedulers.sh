#!/usr/bin/env bash
set -euo pipefail

# scx - nightly builds from Terra (sched_ext schedulers + tools), always latest
dnf install -y scx-tools-nightly scx-scheds-nightly