# Configure kubectl OIDC Login

This guide configures `kubectl` to authenticate to the homelab cluster using
Keycloak. It assumes that your Keycloak user belongs to `/kubernetes/admins`.

## Prerequisites

- The `kubectl oidc-login` plugin is installed and available in `PATH`.
- The Talos Keycloak OIDC patch has been generated and applied.
- Your existing kubeconfig has a working certificate-based context. Keep it as
  a recovery path until the OIDC login has been verified.

## Configure the credential

Back up your kubeconfig, then add the Keycloak exec credential:

```bash
cp ~/.kube/config ~/.kube/config.before-keycloak-oidc

kubectl config set-credentials keycloak-oidc \
  --exec-api-version=client.authentication.k8s.io/v1 \
  --exec-interactive-mode=IfAvailable \
  --exec-command=kubectl \
  --exec-arg=oidc-login \
  --exec-arg=get-token \
  --exec-arg=--oidc-issuer-url=https://keycloak.external.homelab.aliktb.com/realms/homelab \
  --exec-arg=--oidc-client-id=kubernetes-homelab-dev
```

Select this credential for the current context:

```bash
kubectl config set-context --current --user=keycloak-oidc
```

The first Kubernetes request opens a browser for Keycloak authentication. The
client is configured with the local callback URL used by `kubectl oidc-login`.

## Verify access

```bash
kubectl auth whoami
kubectl auth can-i '*' '*' --all-namespaces
```

The identity should include the `oidc:` prefix and group membership should
include `oidc:/kubernetes/admins`. The authorization check should return `yes`.

## Refresh group membership

OIDC group claims are captured when a token is issued. After being added to a
Keycloak group, discard the cached token and make a new authenticated request:

```bash
kubectl oidc-login clean
kubectl auth whoami
```

The second command triggers a new browser login and requests a fresh token. If
the group is still absent, confirm that the user belongs to
`/kubernetes/admins` in Keycloak and that the group mapper has been applied.
