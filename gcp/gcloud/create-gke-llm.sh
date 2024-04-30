#!/bin/bash

set -eoux pipefail

GKE_CLUSTER_NAME="gke-llm"
CLUSTER_VERSION="1.28.7-gke.1026000"
NODEPOOL_NAME="ai-apps"

# ZONE must be set in env vars
if [ -z "$ZONE" ] || \
   [ -z "$CLUSTER_VPC" ] || \
   [ -z "$CLUSTER_SUBNET" ]; then
  echo "Error required env variables are not set" && exit 1
fi

gcloud container clusters create $GKE_CLUSTER_NAME \
    --cluster-version=$CLUSTER_VERSION \
    --zone=$ZONE \
    --node-locations=$ZONE \
    --network=$CLUSTER_VPC \
    --subnetwork=$CLUSTER_SUBNET \
    --enable-dataplane-v2 \
    --workload-pool=${PROJECT_ID}.svc.id.goog \

# this command can't run in background because there is not enough quota
gcloud container node-pools delete default-pool \
    --cluster=$GKE_CLUSTER_NAME \
    --zone=$ZONE \
    --quiet

# https://cloud.google.com/sdk/gcloud/reference/container/node-pools/create#--accelerator
MACHINE_TYPE="n1-standard-8"
ACCELERATOR="type=nvidia-tesla-t4,count=1,gpu-driver-version=latest"
gcloud container node-pools create gpupool-n1 \
    --project=$PROJECT_ID \
    --zone=$ZONE \
    --cluster=$GKE_CLUSTER_NAME \
    --accelerator $ACCELERATOR \
    --machine-type=$MACHINE_TYPE \
    --num-nodes=1 \
    --spot

# GPU availability by zone: https://cloud.google.com/compute/docs/gpus/gpu-regions-zones

# https://cloud.google.com/compute/docs/gpus/create-vm-with-gpus#create_a_vm_that_has_attached_gpus
# To create a VM that has attached NVIDIA H100, A100, or L4 GPUs, see Create an accelerator-optimized VM.
# To create a VM that has attached NVIDIA T4, P4, P100, or V100 GPUs, see Create an N1 VM that has attached GPUs.

gcloud container clusters get-credentials $GKE_CLUSTER_NAME --zone $ZONE --project $PROJECT_ID
