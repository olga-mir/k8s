#!/bin/bash

set -eoux pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)
DIR_PATH=$REPO_ROOT/../anthos-service-mesh-packages

kubectl apply -f $DIR_PATH/samples/online-boutique/kubernetes-manifests/namespaces
