#!/usr/bin/env bash
set -e

source config.env

# Apply the main controlplane config
talosctl apply-config \
  --nodes "$NODE" \
  --file "$OUTPUT_DIR/controlplane.yaml"

# Apply UserVolumeConfig as a separate document
talosctl patch mc \
  --nodes "$NODE" \
  --patch @patches/storage.yaml
