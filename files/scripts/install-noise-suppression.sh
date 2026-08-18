#!/usr/bin/env bash
set -euo pipefail

# noise-suppression-for-voice (werman) - mic noise suppression via RNNoise.
# Not packaged in Fedora; vendor the prebuilt LADSPA plugin from the v1.10 release.
# PipeWire >= 1.6.3 only dlopens plugins from $LADSPA_PATH then /usr/lib64/ladspa,
# so the .so must land there.
dnf install -y unzip
mkdir -p /usr/lib64/ladspa
curl -fL -o /tmp/rnnoise.zip "https://github.com/werman/noise-suppression-for-voice/releases/download/v1.10/linux-rnnoise.zip"
unzip -o /tmp/rnnoise.zip -d /tmp/rnnoise
find /tmp/rnnoise -name 'librnnoise_ladspa.so' -exec install -m 0755 {} /usr/lib64/ladspa/ \;
rm -rf /tmp/rnnoise /tmp/rnnoise.zip

# Enable a system-wide noise-canceling microphone source via a PipeWire filter-chain drop-in.
# label = noise_suppressor_stereo -> the plugin's STEREO descriptor (per-channel processing).
# The nofail flag degrades gracefully if the .so is missing.
cat > /usr/share/pipewire/pipewire.conf.d/99-input-denoising.conf <<'EOF'
context.modules = [
    { name = libpipewire-module-filter-chain
        flags = [ nofail ]
        args = {
            node.description = "Noise Canceling source"
            media.name       = "Noise Canceling source"
            filter.graph = {
                nodes = [
                    {
                        type   = ladspa
                        name   = rnnoise
                        plugin = "librnnoise_ladspa"
                        label  = noise_suppressor_stereo
                        control = {
                            "VAD Threshold (%)" 50.0
                        }
                    }
                ]
            }
            audio.position = [ FL FR ]
            capture.props = {
                node.name = "effect_input.rnnoise"
                node.passive = true
            }
            playback.props = {
                node.name = "effect_output.rnnoise"
                media.class = Audio/Source
            }
        }
    }
]
EOF