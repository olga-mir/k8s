#!/bin/bash
set -eou pipefail

configPath=clusterConfig/mgmt/base

# generates manifest from all jsonnet files found in `clusterConfig` directory into one yaml file
# output to stdin

jsonnet --ext-str ssh_ip_cidr="$(curl -s https://checkip.amazonaws.com)/32" $configPath/cluster.jsonnet | yq e -P -
echo "---"
jsonnet $configPath/controlPlaneNodeGroup.jsonnet  | yq e -P -
echo "---"
jsonnet $configPath/workerNodeGroup.jsonnet | yq e -P -

