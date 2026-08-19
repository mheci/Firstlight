#!/usr/bin/env bash
set -euo pipefail

# scx - stable sched_ext schedulers + tools from Terra main (the nightly packages are
# gone per the stable-only decision). CO-RE BPF userspace schedulers load fine on the
# kernel-cachyos kernel (no per-kernel .ko modules since scx v1.0).
dnf install -y scx-scheds scx-tools

# scx-manager (GTK GUI on top of scx_loader) ships in the kernel-cachyos addons COPR;
# enable the repo via repofrompath only (cannot shadow Terra on upgrades)
dnf install -y --nogpgcheck --repofrompath=addons,https://download.copr.fedorainfracloud.org/results/bieszczaders/kernel-cachyos-addons/fedora-44-x86_64/ scx-manager

# scx_loader is what scx-manager toggles schedulers through - run it at boot
if systemctl list-unit-files scx_loader.service >/dev/null 2>&1; then
  systemctl enable scx_loader
fi

# Per-scheduler config: every scheduler shipped by scx-scheds 1.1.2, tuned for
# aggressive performance / frametime stability (flags verified against the
# v1.1.2 clap definitions in scheds/rust/*/src/main.rs upstream). scx_loader
# switches between modes automatically (default_mode = "Auto"). Note: scx_loader
# (sched-ext/scx-loader v1.1.2) only manages 13 of these; layered/chaos/characterize
# are not in its SupportedSched set - their sections are inert for the loader but
# valid for direct invocation.
mkdir -p /etc/scx_loader
cat > /etc/scx_loader/config.toml <<'EOF'
default_sched = "scx_bpfland"
default_mode = "Auto"

[scheds.scx_bpfland]
# interactive-first vruntime scheduler; 5ms slice, tight slice-lag, preferred idle scan, local kthreads
auto_mode = ["-s", "5000", "-l", "5000", "-P", "-k"]
gaming_mode = ["-s", "5000", "-l", "5000", "-P", "-k"]
lowlatency_mode = ["-s", "2500", "-l", "5000", "-P", "-k"]
powersave_mode = ["-s", "20000", "-l", "40000"]

[scheds.scx_lavd]
# latency-aware virtual deadline; performance mode with a 5ms/500us slice window
auto_mode = ["--performance", "--slice-max-us", "5000", "--slice-min-us", "500"]
gaming_mode = ["--performance", "--slice-max-us", "5000", "--slice-min-us", "500"]
lowlatency_mode = ["--performance", "--slice-max-us", "2500", "--slice-min-us", "250"]
powersave_mode = ["--powersave"]

[scheds.scx_rusty]
# CFS-like rust scheduler; tight overutil slice, greedy direct-kick at 90% underutil
auto_mode = ["-o", "5000", "-k", "-g", "1", "-D", "90"]
gaming_mode = ["-o", "5000", "-k", "-g", "1", "-D", "90"]
lowlatency_mode = ["-o", "2000", "-k", "-g", "1", "-D", "90", "-f"]
powersave_mode = []

[scheds.scx_flash]
# greedy-interactive domain scheduler; 500us slices, RR greedy tasks, cpufreq hints
auto_mode = ["-s", "500", "-R", "-f"]
gaming_mode = ["-s", "500", "-R", "-f"]
lowlatency_mode = ["-s", "300", "-R", "-f"]
powersave_mode = []

[scheds.scx_beerland]
# beerland: interactive-prioritizing scheduler; tight 500us slices
auto_mode = ["-s", "500"]
gaming_mode = ["-s", "500"]
lowlatency_mode = ["-s", "300"]
powersave_mode = ["-s", "20000"]

[scheds.scx_cake]
# PELT-based gaming scheduler; esports profile = 1ms quantum, 50ms starvation
auto_mode = ["--profile", "esports"]
gaming_mode = ["--profile", "esports"]
lowlatency_mode = ["--profile", "esports"]
powersave_mode = ["--profile", "battery"]

[scheds.scx_cosmos]
# GPU-aware scheduler; 500us slices, GPU kprobe monitoring, memory-affinity + preferred idle scan
auto_mode = ["-s", "500", "-g", "-a", "-P"]
gaming_mode = ["-s", "500", "-g", "-a", "-P"]
lowlatency_mode = ["-s", "300", "-g", "-a", "-P"]
powersave_mode = ["-s", "20000"]

[scheds.scx_forge]
# fair scheduler with active preemption; 500us slices, preemption enabled
auto_mode = ["-s", "500", "-p"]
gaming_mode = ["-s", "500", "-p"]
lowlatency_mode = ["-s", "300", "-p"]
powersave_mode = ["-s", "10000"]

[scheds.scx_layered]
# cgroup/layer policy scheduler; 5ms slices, GPU support + GPU affinity, partial cores allowed
auto_mode = ["-s", "5000", "--enable-gpu-support", "--enable-gpu-affinitize", "--allow-partial-core"]
gaming_mode = ["-s", "5000", "--enable-gpu-support", "--enable-gpu-affinitize", "--allow-partial-core"]
lowlatency_mode = ["-s", "2500", "--enable-gpu-support", "--enable-gpu-affinitize", "--allow-partial-core"]
powersave_mode = ["-s", "20000"]

[scheds.scx_p2dq]
# pick-2 domains; performance mode (EPP/uncore/turbo set to max), wakeup preemption + latency priority
auto_mode = ["--sched-mode", "performance", "--wakeup-preemption", "--latency-priority"]
gaming_mode = ["--sched-mode", "performance", "--wakeup-preemption", "--latency-priority"]
lowlatency_mode = ["--sched-mode", "performance", "--wakeup-preemption", "--latency-priority"]
powersave_mode = ["--sched-mode", "efficiency"]

[scheds.scx_pandemonium]
# single-CPU interference research scheduler - requires a CPU to pin to
auto_mode = ["--cpu", "0"]
gaming_mode = ["--cpu", "0"]
lowlatency_mode = ["--cpu", "0"]
powersave_mode = ["--cpu", "0"]

[scheds.scx_rustland]
# vruntime interactive scheduler; 5ms/500us slice window
auto_mode = ["-s", "5000", "-S", "500"]
gaming_mode = ["-s", "5000", "-S", "500"]
lowlatency_mode = ["-s", "2500", "-S", "250"]
powersave_mode = ["-s", "20000", "-S", "1000"]

[scheds.scx_tickless]
# tickless CFS-like scheduler; 5ms slices
auto_mode = ["-s", "5000"]
gaming_mode = ["-s", "5000"]
lowlatency_mode = ["-s", "2500"]
powersave_mode = ["-s", "20000"]

[scheds.scx_flow]
# autotunes itself continuously; no performance flags in 1.1.2
auto_mode = []
gaming_mode = []
lowlatency_mode = []
powersave_mode = []

[scheds.scx_chaos]
# chaos-monkey test scheduler - intentionally degrades the system; kept with defaults
auto_mode = []
gaming_mode = []
lowlatency_mode = []
powersave_mode = []

[scheds.scx_characterize]
# workload characterization tool (record/process/extract subcommands), not a scheduler
auto_mode = []
gaming_mode = []
lowlatency_mode = []
powersave_mode = []
EOF