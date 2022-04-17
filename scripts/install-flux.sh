#!/bin/bash

set -eou pipefail

# repo per team
# https://fluxcd.io/docs/guides/repository-structure/#repo-per-team

# *github* flux bootstrap uses PAT for auth. For using SSH follow
# *generic git server* instructions.

# use existing key or generate a new one according to docs:
# https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
# add public key as a deployment key to the repo.

# Create SSH secret as described in: https://fluxcd.io/docs/components/source/gitrepositories/#ssh-authentication
# `k get secret flux-system -n flux-system` is the secret in the link above (ssh-credentials)


flux bootstrap git \
  --url=ssh://git@github.com/olga-mir/k8s \
  --branch=feature/flux-capi-dev \
  --private-key-file=$HOME/.ssh/flux-github-key \
  --path=clusters/mgmt


# % ./scripts/install-flux.sh
# ► cloning branch "feature/flux-capi-dev" from Git repository "ssh://git@github.com/olga-mir/k8s"
# ✔ cloned repository
# ► generating component manifests
# ✔ generated component manifests
# ✔ component manifests are up to date
# ► installing components in "flux-system" namespace
# ✔ installed components
# ✔ reconciled components
# ► determining if source secret "flux-system/flux-system" exists
# ► generating source secret
# ✔ public key: ...
# Please give the key access to your repository: y
# ► applying source secret "flux-system/flux-system"
# ✔ reconciled source secret
# ► generating sync manifests
# ✔ generated sync manifests
# ✔ sync manifests are up to date
# ► applying sync manifests
# ✔ reconciled sync configuration
# ◎ waiting for Kustomization "flux-system/flux-system" to be reconciled
# ✔ Kustomization reconciled successfully
# ► confirming components are healthy
# ✔ helm-controller: deployment ready
# ✔ kustomize-controller: deployment ready
# ✔ notification-controller: deployment ready
# ✔ source-controller: deployment ready
# ✔ all components are healthy

