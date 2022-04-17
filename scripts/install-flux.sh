#!/bin/bash

set -eou pipefail

# repo per team
# https://fluxcd.io/docs/guides/repository-structure/#repo-per-team

flux bootstrap git \
  --url=ssh://git@github.com/olga-mir/k8s \
  --branch=feature/flux-capi-dev \
  --path=clusters/prod
