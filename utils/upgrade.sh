#!/usr/bin/env bash

# Usage:
#   bash utils/upgrade.sh               # Upgrade Talos OS only
#   bash utils/upgrade.sh --upgrade-k8s # Upgrade Talos OS + Kubernetes

set -e

source config.env


# Upgrade Talos OS
echo "Upgrading Talos to $TALOS_VERSION..."
# This is a single-node cluster. Draining cannot preserve workload availability
# and can time out while evicting many StatefulSet pods.
talosctl upgrade \
  --nodes "$NODE" \
  --image factory.talos.dev/metal-installer/dc8730aa8cc7bfa5ef7e2b3284248f2631135b2faf4ae11aa997a0c1987b0eee:"$TALOS_VERSION" \
  --drain=false \
  --wait

echo "Talos upgrade complete!"
talosctl get member --nodes "$NODE"

# Optionally upgrade Kubernetes
if [[ "${1}" == "--upgrade-k8s" ]]; then
  echo "Upgrading Kubernetes to $K8S_VERSION ..."
  talosctl upgrade-k8s \
    --nodes "$NODE" \
    --to "$K8S_VERSION"
  echo "Kubernetes upgrade complete!"
  kubectl get nodes
fi
