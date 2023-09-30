#!/bin/bash
set -eoux pipefail

# ZONE must be set in env vars
if [ -z "$ZONE" ] || \
   [ -z "$CLUSTER_VPC" ] || \
   [ -z "$SUBNET_DEV" ] || \
   [ -z "$HIGHPERF_VPC" ] || \
   [ -z "$SUBNET_HIGHPERF" ] || \
   [ -z "$HIGHPERF_SEC_RANGE" ]; then
  echo "Error required env variables are not set" && exit 1
fi

GKE_CLUSTER_NAME="multi-network"
CLUSTER_VERSION="1.27.3-gke.1700"
NODEPOOL_DEVICE="device"
NODEPOOL_L3="l3"

# Cluster network: CLUSTER_VPC, SUBNET_DEV

# following tutorial: https://cloud.google.com/kubernetes-engine/docs/how-to/setup-multinetwork-support-for-pods
# additional VPC in the tutorial is `highperf`, keeping this name for now.
# "other" network: HIGHPERF_VPC, SUBNET_HIGHPERF, HIGHPERF_SEC_RANGE

# there is no way in `gcloud` to create a cluster without default nodepool
# use `spot` and delete this nodepool after creation
gcloud container clusters create $GKE_CLUSTER_NAME \
    --cluster-version=$CLUSTER_VERSION \
    --zone=$ZONE \
    --node-locations=$ZONE \
    --location-policy=BALANCED \
    --enable-dataplane-v2 \
    --enable-ip-alias \
    --enable-multi-networking \
    --network=$CLUSTER_VPC \
    --subnetwork=$SUBNET_DEV \
    --default-max-pods-per-node=16 \
    --services-secondary-range-name=secondary-range0 \
    --cluster-secondary-range-name=secondary-range1 \
    --spot \
    --enable-autoscaling \
    --total-max-nodes=1
#    --system-config-from-file=system-config.yaml

# this command can't run in background because there is not enough quota
gcloud container node-pools delete default-pool \
    --cluster=$GKE_CLUSTER_NAME \
    --zone=$ZONE \
    --quiet

# ERROR: (gcloud.container.node-pools.create) ResponseError: code=400,
# message=Number of vCPUs (2) must be greater than or equal to the number of node interfaces (3).
gcloud container node-pools create $NODEPOOL_DEVICE \
    --cluster=$GKE_CLUSTER_NAME \
    --zone=$ZONE \
    --node-locations=$ZONE \
    --location-policy=BALANCED \
    --enable-autoscaling \
    --total-max-nodes=1 \
    --machine-type=e2-highcpu-4 \
    --spot \
    --additional-node-network network=$HIGHPERF_VPC,subnetwork=$SUBNET_HIGHPERF

# L3: additional-pod-network
gcloud container node-pools create $NODEPOOL_L3 \
    --cluster=$GKE_CLUSTER_NAME \
    --zone=$ZONE \
    --node-locations=$ZONE \
    --location-policy=BALANCED \
    --enable-autoscaling \
    --total-max-nodes=1 \
    --spot \
    --additional-node-network network=$HIGHPERF_VPC,subnetwork=$SUBNET_HIGHPERF \
    --additional-pod-network "subnetwork=$SUBNET_HIGHPERF,pod-ipv4-range=$HIGHPERF_SEC_RANGE,max-pods-per-node=16"
