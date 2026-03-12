#!/usr/bin/env bash

set -e

source config.env

# Always remove decrypted secrets on exit, even if the script fails
trap 'rm -f secrets.yaml' EXIT

FILES=("controlplane.yaml" "worker.yaml" "talosconfig")

# Decrypt secrets
sops -d secrets.enc.yaml > secrets.yaml

# Backup existing generated files
for f in "${FILES[@]}"; do
  if [ -f "$OUTPUT_DIR/$f" ]; then
    mv "$OUTPUT_DIR/$f" "$OUTPUT_DIR/$f.bak"
    echo "Backed up $f -> $f.bak"
  fi
done

mkdir -p "$OUTPUT_DIR"

talosctl gen config "$CLUSTER_NAME" "$CLUSTER_ENDPOINT" \
  --with-secrets secrets.yaml \
  --output-dir "$OUTPUT_DIR"
