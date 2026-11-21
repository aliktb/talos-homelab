#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO_DIR/config.env"

echo "etcd status before defragmentation:"
talosctl etcd status --nodes "$NODE"

echo "Defragmenting etcd on $NODE. Kubernetes API requests may pause briefly."
talosctl etcd defrag --nodes "$NODE"

echo "etcd status after defragmentation:"
talosctl etcd status --nodes "$NODE"
