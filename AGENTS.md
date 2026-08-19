# AGENTS.md — Firstlight

Working instructions for AI agents and contributors on this repository. This is a **BlueBuild** repository that produces a Fedora 44 Atomic (bootc) container image, published to GHCR as `ghcr.io/mheci/firstlight`.

## What this image is

A personal, gaming/creative/AI-focused Fedora 44 atomic desktop:

- **Budgie Desktop 10.10.2** — Wayland-ONLY session (no X session), compositor is **labwc 0.9.6** (`startbudgielabwc` → `labwc --config-dir ~/.config/budgie-desktop/labwc -S budgie-desktop`).
- **NVIDIA open drivers (DKMS) + CUDA toolkit** from the NVIDIA fedora44 repo; **Terra mesa** (preferred over Fedora's, epoch-0 vs epoch-1).
- **Kernel**: CachyOS kernel (COPR `bieszczaders/kernel-cachyos`) signed with a persistent MOK key at build time; stock Fedora kernel kept as signed fallback.
- **Terra (repos.fyralabs.com) is the PRIMARY package source**; Fedora base and RPM Fusion (repos only) are fallbacks.
- Gaming: Steam, Proton-CachyOS, umu, faugus-launcher, ScopeBuddy, stable scx schedulers + scx-manager, terra-gamescope, ananicy-cpp, NTSync, gamescope-ready labwc.
- Reliability: greenboot (greenboot-rs) health checks + auto-rollback after 3 failed boots.
- AI: CUDA llama.cpp (conda-forge), Open WebUI (quadlet container), Hermes, Unsloth, glance.
- **Native-only policy**: Flatpak is banned except as an absolute last resort; everything comes from Terra/Fedora, tarballs, AppImage extraction, or source builds.

## Hard constraints (do not violate)

1. **Never delete or recreate this repository.** Only commit/push changes to it.
2. **Never run local builds/downloads of the image** in this session. Lightweight verification via `gh api`/`gh run`/`gh workflow run`, webfetch, or subagent research is allowed.
3. **Never guess — verify.** Before assuming any package/version/behavior, confirm against official docs, package repos (packages.fedoraproject.org, terrapkg github, COPR API), or a research subagent. Cite sources.
4. **Poll CI at intervals ≤ 2 minutes.** Never longer.
5. **No secrets.** `SIGNING_SECRET` and `FIRSTLIGHT_MOK_KEY` live in GitHub secrets (MOK private key also local-only, gitignored); never print or commit them. Remind the user to revoke any exposed PAT when wrapping up.
6. **Never add comments to code unless they add real context** (this repo's scripts use concise purpose comments — match that style).
7. **Never remove the `example.sh` template** and preserve exec bits on all scripts.

## Engineering values & priorities

1. **Native-first packaging.** Prefer, in order: Terra → Fedora base → RPM Fusion repos → official release tarball/AppImage extraction → source build. Only use Flatpak if no reliable native path exists.
2. **Stable-over-nightly (per user decision).** All Terra/Fedora nightlies were replaced with stable packages: yt-dlp + mpv from Fedora, scx-scheds/scx-tools stable from Terra, scx-manager from the CachyOS addons COPR; bpftune-nightly was **dropped** (no stable bpftune exists in Fedora or Terra). bun-installed pi stays. Pin only when upstream has no stable channel.
3. **bootc/atomic correctness.** The image is built inside a container **with no running systemd**:
   - `systemctl daemon-reload`, `systemctl start`, and quadlet enables will FAIL at build time.
   - `systemctl enable <regular-unit>` works offline (symlink ops). For quadlet units, create the enable symlink manually (`ln -sf <name>.container → /etc/systemd/system/multi-user.target.wants/<name>.service`).
   - `/var` is a bootc VOLUME: `setsebool -P` at build does NOT persist → ship a boot-time oneshot unit instead (see `selinux-gaming.sh`).
   - `/usr` is read-only at runtime; per-user state belongs in `/etc/skel` or first-boot services.
4. **Package conflicts are resolved deliberately**: use `--allowerasing` only to erase an explicitly-unwanted conflicting package (e.g. `libfdk-aac`, `zram-generator-defaults`); never to silently drop wanted packages. If a Terra package is broken (e.g. `pi`'s bogus riscv64 Requires), fall back to bun/github and comment why.
5. **No VLC, ever. mpv is the media player.** No Flatpak. No `80-gamecompatibility.conf` naming — the gaming sysctl file is `/etc/sysctl.d/99-gamecompatibility.conf`.
6. **Don't hardcode configs the Budgie labwc bridge manages.** The bridge rewrites rc.xml keybinds marked `bridge="..."`; custom keybinds must NOT carry a `bridge=` attribute. Keep `version="1"` on `<labwc_config>` so the bridge never migrates/replaces the keyboard section.
7. **GitHub-API-free downloads in build scripts** where possible (use `/releases/latest/download/` redirects or master tarballs) — the API rate-limits (403) and broke builds before.

## Repo structure

- `recipes/recipe.yml` — the BlueBuild recipe: `dnf` module (base/driver stack), `files` module (system files → `/`), `script` module (ordered list), `kargs`, `signing`.
- `files/scripts/*.sh` — one script per inclusion. Current set (order matters):
  install-kernel-cachyos, install-latest-tools, enable-terra, swap-mesa-terra, enable-terra-multimedia, dnf-terra-apps, install-scx-schedulers, enable-rpmfusion, dnf-fedora-extras, install-greenboot, install-zen-browser, install-llama-cpp, install-greetd, install-budgie-desktop, install-nautilus, install-themes, selinux-gaming, install-open-webui, install-glance, install-noise-suppression, install-cachyos-settings, install-shader-cache, install-ntsync, install-wl-clip-persist, install-just, install-handlr-regex, install-ab-download-manager, install-proton-cachyos, install-flameget, install-betterbird, install-midori, install-zen-adblocker, install-hermes, install-blackbird, install-unsloth-desktop.
- `files/system/` — shipped files:
  - `usr/share/budgie-desktop/labwc/rc.xml` — production rc.xml (adaptive sync, tearing, reuseOutputMode, gamescope rule, W-r rofi, W-v cliphist) + `environment` (NVIDIA env).
  - `etc/dconf/`, `etc/sysctl.d/99-gamecompatibility.conf`, `etc/xdg/autostart/` (cliphist, wl-clip-persist), `etc/skel/justfile` + `etc/skel/.config/budgie-desktop/labwc/autostart`.
  - `etc/pki/firstlight-mok/` — MOK public certs (cert.pem, db.der). **priv.pem is gitignored** and injected from the `FIRSTLIGHT_MOK_KEY` secret at build time.
- `.github/workflows/`:
  - `build.yml` — the BlueBuild image build (blue-build/github-action), **concurrency cancel-in-progress** (a scheduled run will cancel a manual dispatch on the same ref). **Checkouts manually** (`actions/checkout`) and uses `skip_checkout: "true"` on the blue-build action — the action's own checkout would reset the workspace from git and **wipe the gitignored MOK private key** injected by the "Inject MOK signing key" step (base64 from the `FIRSTLIGHT_MOK_KEY` secret) before the build.
  - `security.yml` — OpenSSF Scorecard + SBOM.
  - (lint.yml/codeql.yml were removed during the clean-slate rewrite; only build.yml + security.yml exist.)
- `cosign.pub` — image signing key.

## Build & verification workflow

1. Make changes; ensure new scripts are listed in `recipes/recipe.yml` and have the exec bit.
2. `git add -A && git commit -m "<summary>" && git push`.
3. Trigger a build: `gh workflow run build.yml --repo mheci/Firstlight` (the push may already auto-build).
4. Poll: `gh run view <id> --repo mheci/Firstlight --json status,conclusion` — **at most every 2 minutes**; wait for `completed success`.
5. On failure: `gh run view <id> --repo mheci/Firstlight --log-failed` and fix the root cause.
6. (ISO builds were removed; the forked `mheci/build-container-installer` repo and its image were deleted.)

## Key technical facts (verified; avoid re-researching)

- Terra bootstrap: `dnf install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release terra-gpg-keys`, then priority via `sed -i 's/^\[terra\(.*\)\]/[terra\1]\npriority=1/' /etc/yum.repos.d/terra.repo /etc/yum.repos.d/terra-mesa.repo`.
- Mesa: `dnf downgrade -y --disablerepo=fedora --disablerepo=updates mesa-dri-drivers mesa-vulkan-drivers mesa-libGL mesa-libEGL mesa-libgbm` (Terra epoch 0 vs Fedora epoch 1).
- fdk-aac: `dnf install -y --allowerasing fdk-aac fdk-aac.i686` (Fedora `libfdk-aac` Obsoletes conflict).
- RPM Fusion: repos only (`enable-rpmfusion.sh`); `gstreamer1-plugins-bad-freeworld/ugly` deliberately excluded (x265-libs 4.1 vs Terra 4.2).
- labwc outputs are configured via wlr-randr/kanshi (no `<outputs>` in rc.xml); max res/refresh = preferred mode via `autoEnableOutputs`.
- NVIDIA env for the session lives in `~/.config/budgie-desktop/labwc/environment` (`GBM_BACKEND=nvidia-drm`, `__GLX_VENDOR_LIBRARY_NAME=nvidia`); system-wide in `/etc/environment` (shader caches).
- `lollypop` IS included (was excluded while it conflicted with Terra's yt-dlp-git; the conflict is gone with Fedora's stable yt-dlp).
- `pi` (Terra) is broken (bogus riscv64 Requires) → installed via bun. `nix` was removed (Determinate installer incompatible with bootc builds). `scx-manager` comes from the CachyOS addons COPR (`--repofrompath`, never globally enabled).
- **kernel-cachyos + Secure Boot**: kernel + devel install in `install-kernel-cachyos.sh` (NOT the dnf module) with `--setopt=tsflags=noscripts`: the cachyos kernel-core %posttrans runs `kernel-install`/dracut before its own kernel-modules %posttrans depmod, so the dracut step dies on a missing modules.dep in container builds (`/run/ostree-booted` guard doesn't exist there). Scriptlets are safe to skip — bootc generates initramfs + BLS entries on the machine at deploy. The script then runs `depmod` **per installed kernel version** (plain `depmod -a` resolves `uname -r`, which inside the build container is the host runner kernel, e.g. `6.17.0-1022-azure`, that has no /lib/modules dir — it must never be used), installs `kmod-nvidia-open-dkms` + `nvidia-driver` (dkms %post builds for both stock and cachyos kernels; `nvidia-open` is precompiled for the stock kernel only and must NOT be used), and signs: `sbsign` each `/usr/lib/modules/<kver>/vmlinuz` (skip if already signed by our cert), then `xz -d` every `.ko.xz` (signature must go on the uncompressed ELF) and `scripts/sign-file sha256 priv.pem db.der` every `.ko`. Requires `FIRSTLIGHT_MOK_KEY` secret (base64 PKCS8 PEM) + shipped cert.pem/db.der; build fails loudly if missing. Enroll once per machine: `sudo mokutil --import /etc/pki/firstlight-mok/db.der` (+ 2 reboots). Stock kernel stays as unsigned-fallback entry until then.
- **greenboot**: packages `greenboot` + `greenboot-default-health-checks` (the Rust rewrite, v0.16.x, present in Fedora 44 release/updates repos — verify with the mirror listing, NOT packages.fedoraproject.org which is stale for this package). `install-greenboot.sh` enables `greenboot-healthcheck.service`; the default-health-checks subpackage ships the network-online drop-in.
- **terra-gamescope** comes from the Terra extras subrepo (`terra-release-extras`, keeps its shipped priority=150; the explicit package name wins over Fedora's gamescope). It carries a `Conflicts` on Fedora's `gamescope` (pulled in as a dep, e.g. by mangohud/steam), so it must be installed with `--allowerasing`. Non-fatal noise during the Terra apps dnf: `Failed to preset unit: Unit ananicy-cpp.service does not exist` (Terra's ananicy-cpp %post presets a differently-named unit).
- GHCR version `1137159731` is undeletable (>5000 downloads) — requires GitHub support.
