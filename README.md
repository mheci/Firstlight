# Firstlight &nbsp; [![bluebuild build badge](https://github.com/mheci/firstlight/actions/workflows/build.yml/badge.svg)](https://github.com/mheci/firstlight/actions/workflows/build.yml)

Firstlight is a personal Fedora 44 Atomic (bootc) image: **Budgie Desktop 10.10 on the labwc Wayland compositor**, NVIDIA open drivers + CUDA, Terra-first packaging, gaming/creative/AI tooling, and native-only apps.

## Highlights

- **Desktop**: Budgie Desktop 10.10.2 (Wayland-only) powered by labwc 0.9.6 as its compositor (`startbudgielabwc`), with a production-tuned rc.xml (adaptive sync, fullscreen tearing for input lag, flicker-free output, gamescope rule) and NVIDIA wlroots env (GBM nvidia-drm).
- **Login**: greetd + a GTK greeter (cage, multi-head), Wayland-native sessions.
- **Graphics**: NVIDIA open kernel modules (`kmod-nvidia-open-dkms`, DKMS-built for every kernel) + CUDA toolkit (NVIDIA fedora44 repo), Terra mesa (full codec + amdgpu-virtio build) via priority, system-wide shader cache tuning (`/etc/environment`).
- **Kernel**: CachyOS kernel (BORE/1000Hz, sched_ext, NTSync) from COPR `bieszczaders/kernel-cachyos`, **signed at build time with a persistent MOK key** for Secure Boot; stock Fedora kernel kept as fallback until the MOK is enrolled.
- **Gaming**: Steam (+ Proton-CachyOS baked tarball + per-user installer), umu-launcher, faugus-launcher, ScopeBuddy, terra-gamescope, stable scx sched_ext schedulers + scx-manager, ananicy-cpp, NTSync autoload (world-rw device), SELinux gaming booleans at boot.
- **AI**: CUDA llama.cpp (conda-forge), Open WebUI (quadlet container), Hermes Agent, Unsloth Desktop, Glance dashboard, plus `just` + `/etc/skel/justfile` command hub.
- **Reliability**: greenboot (greenboot-rs) boot health checks — a failed boot reboots, then auto-rolls back to the previous deployment after 3 failed attempts.
- **Native-only policy**: no Flatpak anywhere; apps are installed from Terra/Fedora, or baked from tarballs/AppImage extraction/source builds.

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
- `files/scripts/*.sh` — one script per inclusion (Terra bootstrap, mesa swap, apps, DE, services, AI, etc.).
- `files/system/*` — shipped config (labwc rc.xml/environment, dconf defaults, sysctls, XDG autostart, /etc/skel, MOK certs).
- `.github/workflows/` — `build.yml` (image, incl. MOK key injection), `security.yml` (Scorecard + SBOM).

## Verification

Images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). Verify with the `cosign.pub` key in this repo:

```bash
cosign verify --key cosign.pub ghcr.io/mheci/firstlight
```

See [AGENTS.md](AGENTS.md) for the full image contents, build conventions, and engineering values.
