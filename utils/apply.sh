#!/usr/bin/env bash
set -e

source config.env

# Apply the main control plane config and standalone storage document together.
talosctl apply-config \
  --nodes "$NODE" \
  --file "$OUTPUT_DIR/controlplane.yaml" \
  --config-patch @patches/storage.yaml
