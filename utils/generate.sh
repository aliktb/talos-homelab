#!/usr/bin/env bash

set -e

source config.env

# Always remove decrypted secrets on exit, even if the script fails
trap 'rm -f secrets.yaml patches/gitlab-registry.yaml patches/scaleway-registry.yaml' EXIT

FILES=("controlplane.yaml" "worker.yaml" "talosconfig")

# Decrypt secrets
sops -d secrets.enc.yaml > secrets.yaml
sops -d patches/gitlab-registry.enc.yaml > patches/gitlab-registry.yaml
sops -d patches/scaleway-registry.enc.yaml > patches/scaleway-registry.yaml

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
  --config-patch-control-plane patches/enable-workloads-on-controlplane.yaml \
  --config-patch-control-plane patches/install.yaml \
  --config-patch-control-plane patches/network.yaml \
  --config-patch-control-plane patches/kubelet-extra-args.yaml \
  --config-patch-control-plane patches/gcp-workload-identity.yaml \
  --config-patch-control-plane patches/keycloak-oidc.yaml \
  --config-patch-control-plane patches/enable-load-balancer.yaml \
  --config-patch-control-plane patches/metrics-server.yaml \
  --config-patch-control-plane patches/etcd-metrics.yaml \
  --config-patch patches/gitlab-registry.yaml \
  --config-patch patches/scaleway-registry.yaml \
  --output-dir "$OUTPUT_DIR"
