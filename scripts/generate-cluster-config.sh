#!/bin/bash
set -eou pipefail

# generates manifest from all jsonnet files found in `clusterConfig` directory into one yaml file
# output to stdin

jsonnet --ext-str ssh_ip_cidr="$(curl -s https://checkip.amazonaws.com)/32" clusterConfig/cluster.jsonnet | yq e -P -
echo "---"
jsonnet clusterConfig/controlPlaneNodeGroup.jsonnet  | yq e -P -
echo "---"
jsonnet clusterConfig/workerNodeGroup.jsonnet | yq e -P -
