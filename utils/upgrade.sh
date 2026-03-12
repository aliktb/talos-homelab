#!/usr/bin/env bash

# Usage:
#   bash utils/upgrade.sh               # Upgrade Talos OS only
#   bash utils/upgrade.sh --upgrade-k8s # Upgrade Talos OS + Kubernetes

set -e

source config.env


# Upgrade Talos OS
echo "Upgrading Talos to $TALOS_VERSION..."
talosctl upgrade \
  --nodes "$NODE" \
  --image ghcr.io/siderolabs/installer:"$TALOS_VERSION" \
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
