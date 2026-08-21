# Firstlight &nbsp; [![bluebuild build badge](https://github.com/mheci/firstlight/actions/workflows/build.yml/badge.svg)](https://github.com/mheci/firstlight/actions/workflows/build.yml)

Firstlight is a personal Fedora 44 Atomic (bootc) image: **Fedora Kinoite (KDE Plasma 6)** with NVIDIA open drivers + CUDA, Terra-first packaging, gaming/creative/AI tooling, and native-only apps — Plasma tuned for performance and NVIDIA Wayland.

## Highlights

- **Desktop**: KDE Plasma 6 (Kinoite base, stock package set). Themes: **Klassy** (window decorations), **Darkly** (widget style), **Bibata** cursors, **Breeze-Plus** icons, **Fluent** look-and-feel, **Vapor** (Steam Deck look, from the Bazzite COPR) — all prebuilt RPMs, defaults applied image-wide.
- **KWin scripts** (vendored, enabled system-wide): **Krohnkite** dynamic tiling + **Alt-F4 Desktop** (Alt+F4 on the desktop shows the logout prompt).
- **Login**: SDDM (Plasma's Wayland display manager).
- **Graphics**: NVIDIA open kernel modules (`kmod-nvidia-open-dkms`, DKMS-built for every kernel) + CUDA toolkit (NVIDIA fedora44 repo), Terra mesa (full codec + amdgpu-virtio build) via priority, system-wide shader cache tuning (`/etc/environment` incl. NVIDIA GL cache sizing + Qt shader caches), NVIDIA GLX vendor forced.
- **Kernel**: CachyOS kernel (BORE/1000Hz, sched_ext, NTSync) from COPR `bieszczaders/kernel-cachyos`, **signed on each machine with a machine-local MOK key** (Secure Boot); stock Fedora kernel kept as signed fallback until enrollment.
- **Gaming**: Steam (+ Proton-CachyOS baked tarball + per-user installer), umu-launcher, faugus-launcher, ScopeBuddy, terra-gamescope, stable scx sched_ext schedulers + scx-manager, ananicy-cpp, NTSync autoload (world-rw device), SELinux gaming booleans at boot.
- **CLI**: Rust-first utilities (ripgrep, fd, bat, eza, zoxide, du-dust, procs, starship, bottom) + kitty, fastfetch, zsh.
- **AI**: CUDA llama.cpp (conda-forge), whisper.cpp (official prebuilt binaries), Open WebUI (quadlet container), Hermes Agent, Unsloth Desktop, Glance dashboard, plus `just` + `/etc/skel/justfile` command hub.
- **Reliability**: greenboot (greenboot-rs) boot health checks — a failed boot reboots, then auto-rolls back to the previous deployment after 3 failed attempts. Coredumps fully disabled (clean logs).
- **Native-only policy**: no Flatpak anywhere; apps are installed from Terra/Fedora, or baked from prebuilt tarballs/binaries. **Nothing is built from source** (whisper.cpp, wl-clip-persist, llama.cpp, etc. all use prebuilt packages/binaries).

## Installation

> [!WARNING]
> [This is an experimental feature](https://www.fedoraproject.org/wiki/Changes/OstreeNativeContainerStable), try at your own discretion.

Rebase an existing atomic Fedora install to the latest build:

```bash
# First rebase to the unsigned image to get signing keys/policies installed
rpm-ostree rebase ostree-unverified-registry:ghcr.io/mheci/firstlight:latest
systemctl reboot
# Then rebase to the signed image
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/mheci/firstlight:latest
systemctl reboot
```

The `latest` tag tracks the newest build; the image stays pinned to Fedora 44.

## Secure Boot (CachyOS kernel)

Secure Boot is handled **on each machine**, not in the image: the image ships no
private key (it was removed in the 2026-08-20 rework — nothing machine-specific is
baked into the public image). On first boot, `firstlight-sb-sign.service` runs
automatically and:

1. generates a machine-local MOK keypair in `/var/lib/firstlight-mok`,
2. signs the CachyOS kernel and all modules of every deployment on disk,
3. queues the one-time MOK enrollment with a random password.

Then **reboot once**: the MOK Manager appears before boot → *Enroll MOK* → accept →
enter the displayed password. After that every future update is signed automatically
(the service re-signs staged kernels at every boot — nothing to redo).

Manual control via `just` (run from your user account):

```bash
just sb-setup     # sign everything + queue enrollment (same as the boot service)
just sb-status    # Secure Boot state, key, enrollment status
just sb-enroll    # re-queue the enrollment request (reboot to complete)
```

The stock Fedora kernel keeps its Fedora signature and is the fallback GRUB entry,
so the machine always boots even before the MOK is enrolled.

## Repo layout

- `recipes/recipe.yml` — BlueBuild recipe (dnf module + files module + ordered script modules + kargs + signing).
- `files/scripts/*.sh` — one script per inclusion (Terra bootstrap, mesa swap, Plasma theming, apps, services, AI, etc.).
- `files/system/*` — shipped config (sysctls, udev rules, systemd units, XDG autostart, KWin scripts, coredump disable, /etc/skel justfile).
- `.github/workflows/` — `build.yml` (image), `security.yml` (Scorecard + SBOM + advisory image scan).

## Verification

Images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). Verify with the `cosign.pub` key in this repo:

```bash
cosign verify --key cosign.pub ghcr.io/mheci/firstlight
```

See [AGENTS.md](AGENTS.md) for the full image contents, build conventions, and engineering values.