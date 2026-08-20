#!/usr/bin/env bash
set -euo pipefail

# kernel-cachyos (BORE/1000Hz, sched_ext, NTSync patched in) from the CachyOS COPR, plus
# NVIDIA DKMS modules built against it. The stock Fedora kernel stays as the Secure Boot
# fallback (Fedora-signed) until the machine's own MOK key is enrolled.

# Persistent COPR repo (kernel updates flow through image rebuilds like everything else)
dnf config-manager addrepo --from-repofile=https://copr.fedorainfracloud.org/coprs/bieszczaders/kernel-cachyos/repo/fedora-44/bieszczaders-kernel-cachyos-fedora-44.repo

# Install with tsflags=noscripts: the cachyos kernel-core %posttrans runs kernel-install ->
# dracut, but its depmod lives in kernel-modules %posttrans which runs AFTER it, so dracut
# dies on a missing modules.dep inside the build container (guarded by /run/ostree-booted
# which does not exist there). Skipping scriptlets is safe: bootc generates initramfs and
# BLS entries on the machine at deploy time.
dnf install -y --setopt=tsflags=noscripts kernel-cachyos kernel-cachyos-devel-matched

# modules.dep for both kernels (dkms + first-boot dracut need it). Run per version:
# plain `depmod -a` resolves uname -r, which inside the build container is the host
# runner kernel (e.g. 6.17.0-1022-azure) that has no /lib/modules dir here.
for kver in /usr/lib/modules/*/; do
  kver=$(basename "$kver")
  depmod "$kver"
done

# NVIDIA open kernel modules via DKMS (noarch, builds for every installed kernel incl.
# cachyos; nvidia-open would be stock-kernel-only). Install after the cachyos kernel so
# the dkms %post builds for both. Ensure the /usr/lib/modules/<kver>/build symlinks exist.
for kdir in /usr/lib/modules/*/; do
  kver=$(basename "$kdir")
  if [ -d "/usr/src/kernels/$kver" ] && [ ! -L "$kdir/build" ]; then
    ln -s "/usr/src/kernels/$kver" "$kdir/build"
    ln -s "$kdir/build" "$kdir/source"
  fi
done
dnf install -y kmod-nvidia-open-dkms nvidia-driver

# keep the persistence daemon alive so the GPU stays out of D3 during idle
systemctl enable nvidia-persistenced

# Secure Boot is handled at RUNTIME on each machine by install-secureboot.sh:
# the image ships no private key, and kernels/modules are signed on the machine with
# a locally generated MOK key (just sb-setup / the firstlight-sb-sign boot service).