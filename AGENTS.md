# AGENTS.md

## Purpose

This repository manages Talos-based cluster bootstrap and node configuration.
It is the source of truth for:

- Talos machine config inputs
- Talos config patches
- generated Talos machine config artifacts
- local kubeconfig / talosconfig generation workflows

Use this repo when the change affects cluster bring-up, Talos API behavior,
node-level configuration, or the generated machine config pipeline.

## Repository Layout

- `config.env`
  - primary cluster values such as endpoint, versions, node IP, and output dir
- `secrets.enc.yaml`
  - encrypted Talos secrets used during generation
- `patches/`
  - Talos config patches, including storage and identity-related changes
- `generated/`
  - generated machine configs and `talosconfig`; treat as derived output
- `utils/`
  - helper scripts for generate, apply, upgrade, and kubeconfig flows

## Normal Workflow

1. Edit `config.env` or files under `patches/`.
2. Run `bash utils/generate.sh`.
3. Run `bash utils/config-talosctl.sh`.
4. Run `bash utils/apply.sh`.
5. Run `bash utils/get-kubeconfig.sh` if Kubernetes client access needs to be
   refreshed.

Common commands:

- `bash utils/generate.sh`
- `bash utils/config-talosctl.sh`
- `bash utils/apply.sh`
- `bash utils/get-kubeconfig.sh`
- `bash utils/upgrade.sh`

## Editing Guidance

- Prefer changing `config.env`, encrypted secrets, or files in `patches/`
  rather than editing files under `generated/` by hand.
- Treat `generated/` as disposable output that should be reproducible from the
  source inputs.
- Be careful with API server identity or audience settings; those can affect
  Kubernetes auth flows and integrations used by other repos.
- Keep script-driven workflows intact unless there is a clear benefit to
  changing the operator flow.

## Cross-Repo Boundaries

- If the change is about live Kubernetes manifests, Flux resources, or app
  rollout behavior, it likely belongs in `homelab-flux`, not here.
- If the change is about Keycloak realms, OIDC clients, or other Terraform /
  OpenTofu-managed identity objects, it belongs in `homelab-opentofu`.
- If Talos behavior changes create new operational steps, capture those followup
  docs in `homelab-docs`.

## Safety Notes

- `bash utils/apply.sh` and `bash utils/upgrade.sh` affect live nodes. Review
  inputs before running them.
- `bash utils/get-kubeconfig.sh` writes `kubeconfig` in the repo root.
- Scripts temporarily decrypt secret material during generation; avoid adding
  alternate ad hoc secret-handling flows unless necessary.
