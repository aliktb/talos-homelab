# Intel iGPU support

The Talos node runs directly on the Minisforum MS-01. Its Intel integrated GPU
is used for Jellyfin hardware transcoding.

## Talos Image Factory

Talos does not include the Intel DRM driver in its base image. The node instead
uses an Image Factory installer image with the official `siderolabs/i915`
system extension. This provides the Intel GPU firmware and kernel modules.

The Image Factory schematic is content-addressed. This repository uses the
following schematic, which contains only the `i915` extension:

```text
dc8730aa8cc7bfa5ef7e2b3284248f2631135b2faf4ae11aa997a0c1987b0eee
```

Its canonical schematic is:

```yaml
customization:
  systemExtensions:
    officialExtensions:
    - siderolabs/i915
```

`patches/intel-igpu.yaml` pins the installer image used in generated machine
configuration. `utils/upgrade.sh` uses the same schematic with the
`TALOS_VERSION` from `config.env`; keep the patch's tag aligned when changing
that version for a fresh installation.

The Image Factory selects the extension version matching the requested Talos
version. To inspect or recreate the schematic, use the Image Factory API:

```bash
curl --fail --silent --show-error --request POST \
  https://factory.talos.dev/schematics \
  --header 'Content-Type: application/yaml' \
  --data-binary $'customization:\n  systemExtensions:\n    officialExtensions:\n      - siderolabs/i915\n'
```

The command returns the same ID when given this exact schematic.

## Rollout and verification

Changing the generated machine configuration alone does not install system
extensions on an existing node. When replacing a previously installed Talos
image, use a newer Talos patch version: reinstalling the same version can leave
the existing boot asset selected. Regenerate and apply the configuration, then
install the newer i915-enabled image:

```bash
bash utils/generate.sh
bash utils/apply.sh
bash utils/upgrade.sh
```

The upgrade helper skips Kubernetes draining because this is a single-node
cluster: draining cannot preserve availability and can leave the node cordoned
when a large eviction batch times out. The node reboots as part of the upgrade.
After it returns, verify the runtime extension and DRM device:

```bash
talosctl get extensions --nodes "$NODE"
talosctl ls /dev/dri --nodes "$NODE"
```

Expect `i915` in the extensions list and a render device such as
`/dev/dri/renderD128`. Jellyfin also needs a separate deployment change in
`homelab-flux-private` to expose that device to its pod and enable QSV or
VA-API.

## References

- [Talos Image Factory](https://docs.siderolabs.com/talos/v1.13/learn-more/image-factory)
- [Talos boot assets](https://docs.siderolabs.com/talos/v1.13/platform-specific-installations/boot-assets)
- [Talos system extensions](https://github.com/siderolabs/extensions#direct-rendering-manager-drm)
