#!/usr/bin/env bash
set -euo pipefail

source config.env

TARGET_NODE="${CONTROL_PLANE_IP:-$NODE}"

talosctl config endpoint "$TARGET_NODE"
talosctl config node "$TARGET_NODE"
