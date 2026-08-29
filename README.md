# Talos Homelab

This repo manages a Talos-based homelab cluster from generated machine configs plus a small set of helper scripts.

The normal workflow is:

1. Set cluster values in `config.env`.
2. Generate Talos configs with `bash utils/generate.sh`.
3. Point `talosctl` at the control plane with `bash utils/config-talosctl.sh`.
4. Apply the config with `bash utils/apply.sh`.
5. Fetch kubeconfig with `bash utils/get-kubeconfig.sh`.

## Prerequisites

Install these locally:

- `talosctl`
- `sops`
- `kubectl`
- `curl`

To install `talosctl` into `~/.local/bin`:

```bash
bash utils/update-talosctl.sh
```

Or install a specific version:

```bash
bash utils/update-talosctl.sh v1.12.5
```

## Repo Layout

- `config.env`: cluster-specific values used by the scripts
- `secrets.enc.yaml`: encrypted Talos secrets
- `patches/`: Talos config patches, including encrypted registry credentials
- `docs/`: operator documentation, including the Intel iGPU image workflow
- `generated/`: generated machine configs and `talosconfig`
- `utils/`: helper scripts for generate/apply/upgrade flows

## Configuration

Edit [`config.env`](/home/ali/code/talos-homelab/config.env) before generating configs:

```bash
CLUSTER_ENDPOINT="https://192.168.0.97:6443"
CLUSTER_NAME="homelab-cluster"
K8S_VERSION="v1.35.0"
NODE="192.168.0.97"
OUTPUT_DIR="generated"
TALOS_VERSION="v1.12.5"
```

Notes:

- `NODE` is the Talos node targeted by `apply.sh` and `upgrade.sh`.
- `OUTPUT_DIR` is where generated files are written.
- `generate.sh` decrypts secrets temporarily and removes the decrypted files on exit.

## Typical Usage

### 1. Generate Talos configs

```bash
bash utils/generate.sh
```

This will:

- decrypt `secrets.enc.yaml` and the encrypted registry patches
- back up existing generated files to `*.bak`
- generate fresh `controlplane.yaml`, `worker.yaml`, and `talosconfig` into `generated/`

### 2. Point `talosctl` at the control plane

```bash
bash utils/config-talosctl.sh
```

This sets the current `talosctl` endpoint and node to `CONTROL_PLANE_IP` if present, otherwise `NODE` from `config.env`.

### 3. Apply the generated config

```bash
bash utils/apply.sh
```

This:

- applies `generated/controlplane.yaml`
- applies the storage patch from `patches/storage.yaml`

### 4. Fetch kubeconfig

```bash
bash utils/get-kubeconfig.sh
```

This writes `kubeconfig` into the repo root.

## Upgrades

Upgrade Talos only:

```bash
bash utils/upgrade.sh
```

Upgrade Talos and Kubernetes:

```bash
bash utils/upgrade.sh --upgrade-k8s
```

The versions come from `TALOS_VERSION` and `K8S_VERSION` in `config.env`.
Talos upgrades use the custom Intel iGPU installer image; see
[Intel iGPU support](docs/intel-igpu.md).

## Optional Shell Environment

If you want local commands to use this repo's generated configs by default, export:

```bash
export TALOSCONFIG="$PWD/generated/talosconfig"
export KUBECONFIG="$PWD/kubeconfig"
```

If you use `direnv`, create a local `.envrc` file:

```bash
export TALOSCONFIG="$PWD/generated/talosconfig"
export KUBECONFIG="$PWD/kubeconfig"
```

Then allow it once:

```bash
direnv allow
```

`.envrc` is ignored by git, so this stays local to your machine.

## Script Reference

- `bash utils/generate.sh`: generate Talos machine configs from `config.env`, secrets, and patches
- `bash utils/config-talosctl.sh`: set the active Talos endpoint/node
- `bash utils/apply.sh`: apply the control plane config and storage patch
- `bash utils/get-kubeconfig.sh`: fetch cluster kubeconfig into the repo
- `bash utils/upgrade.sh`: upgrade Talos, optionally Kubernetes too
- `bash utils/update-talosctl.sh`: install or update `talosctl`
