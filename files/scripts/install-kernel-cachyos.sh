#!/usr/bin/env bash
set -euo pipefail

# kernel-cachyos (BORE/1000Hz, sched_ext, NTSync patched in) from the CachyOS COPR, plus
# NVIDIA DKMS modules built against it. The stock Fedora kernel stays as the unsigned-boot
# fallback until the MOK is enrolled.

# Persistent COPR repo (kernel updates flow through image rebuilds like everything else)
dnf config-manager addrepo --from-repofile=https://copr.fedorainfracloud.org/coprs/bieszczaders/kernel-cachyos/repo/fedora-44/bieszczaders-kernel-cachyos-fedora-44.repo

# Install with tsflags=noscripts: the cachyos kernel-core %posttrans runs kernel-install ->
# dracut, but its depmod lives in kernel-modules %posttrans which runs AFTER it, so dracut
# dies on a missing modules.dep inside the build container (guarded by /run/ostree-booted
# which does not exist there). Skipping scriptlets is safe: bootc generates initramfs and
# BLS entries on the machine at deploy time.
dnf install -y --setopt=tsflags=noscripts kernel-cachyos kernel-cachyos-devel-matched

# modules.dep for both kernels (dkms + first-boot dracut need it)
depmod -a

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

# Secure Boot: the CachyOS kernel is NOT signed by Fedora - with Secure Boot on,
# shim/GRUB refuse it and kernel lockdown (integrity) refuses unsigned modules.
# Sign the kernel (PE) with sbsign and every module (ELF) with kernel's sign-file, using a
# stable MOK keypair: cert + key are injected at build time via the files module, the
# private key comes from the FIRSTLIGHT_MOK_KEY Actions secret (base64 PEM, gitignored).
# One-time enrollment per machine: sudo mokutil --import /etc/pki/firstlight-mok/db.der
# (reboot -> Enroll MOK -> password -> reboot). Modules are compressed (.ko.xz) in the
# image; the signature must be appended to the uncompressed ELF, so decompress in place
# (kmod loads plain .ko fine).
MOK=/etc/pki/firstlight-mok
[ -f "$MOK/priv.pem" ] || {
  echo "::error::MOK private key missing ($MOK/priv.pem) - set the FIRSTLIGHT_MOK_KEY secret (base64 of priv.pem); Secure Boot machines cannot boot the CachyOS kernel without it." >&2
  exit 1
}
[ -f "$MOK/cert.pem" ] || { echo "::error::MOK certificate missing ($MOK/cert.pem)" >&2; exit 1; }
[ -f "$MOK/db.der" ] || { echo "::error::MOK DER certificate missing ($MOK/db.der)" >&2; exit 1; }

dnf install -y sbsigntools xz

SIGN_FILE=$(ls /usr/src/kernels/*/scripts/sign-file 2>/dev/null | head -n1)
[ -n "$SIGN_FILE" ] || { echo "::error::sign-file not found under /usr/src/kernels (kernel-cachyos-devel not installed?)" >&2; exit 1; }

for kdir in /usr/lib/modules/*/; do
  kver=$(basename "$kdir")
  [ -f "$kdir/vmlinuz" ] || continue
  echo "Signing kernel + modules for $kver"

  if ! sbverify --cert "$MOK/cert.pem" "$kdir/vmlinuz" >/dev/null 2>&1; then
    sbsign --key "$MOK/priv.pem" --cert "$MOK/cert.pem" --output "$kdir/vmlinuz.signed" "$kdir/vmlinuz"
    mv -f "$kdir/vmlinuz.signed" "$kdir/vmlinuz"
  fi

  find "$kdir" -name '*.ko.xz' -print0 | xargs -0 -r -n1 xz -d
  find "$kdir" -name '*.ko' -print0 | xargs -0 -r -n1 -P"$(nproc)" "$SIGN_FILE" sha256 "$MOK/priv.pem" "$MOK/db.der"
done

echo "Secure Boot signing complete"