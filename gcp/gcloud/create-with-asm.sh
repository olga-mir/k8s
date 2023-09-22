#!/bin/bash
set -eoux pipefail

# GKE cluster with managed ASM
# https://cloud.google.com/service-mesh/docs/unified-install/install-anthos-service-mesh-command#local-computer

# ZONE must be set in env vars
if [ -z "$ZONE" ] || \
   [ -z "$CLUSTER_VPC" ] || \
   [ -z "$PROJECT_ID" ] || \
   [ -z "$PROJECT_NUMBER" ] || \
   [ -z "$SUBNET_DEV" ]; then
  echo "Error required env variables are not set" && exit 1
fi

CLUSTER_NAME="asm1"
CLUSTER_VERSION="1.27.3-gke.1700"
NODEPOOL_NAME="apps"
MACHINE_TYPE="e2-standard-4"
CLUSTER_LOCATION=$ZONE

# there is no way in `gcloud` to create a cluster without default nodepool
gcloud container clusters create $CLUSTER_NAME \
    --cluster-version=$CLUSTER_VERSION \
    --zone=$ZONE \
    --node-locations=$ZONE \
    --location-policy=BALANCED \
    --enable-dataplane-v2 \
    --enable-ip-alias \
    --network=$CLUSTER_VPC \
    --subnetwork=$SUBNET_DEV \
    --default-max-pods-per-node=32 \
    --enable-autoscaling \
    --workload-pool=${PROJECT_ID}.svc.id.goog \
    --labels="mesh_id=proj-$PROJECT_NUMBER" \
    --spot

# this command can't run in background because there is not enough quota
gcloud container node-pools delete default-pool \
    --cluster=$CLUSTER_NAME \
    --zone=$ZONE \
    --quiet

gcloud container node-pools create $NODEPOOL_NAME \
    --cluster=$CLUSTER_NAME \
    --zone=$ZONE \
    --node-locations=$ZONE \
    --location-policy=BALANCED \
    --enable-autoscaling \
    --machine-type=$MACHINE_TYPE \
    --spot

gcloud container fleet mesh enable --project $PROJECT_ID

gcloud container fleet memberships register $CLUSTER_NAME-membership \
  --gke-cluster=$CLUSTER_LOCATION/$CLUSTER_NAME \
  --enable-workload-identity \
  --project $PROJECT_ID

gcloud container fleet mesh update \
  --management automatic \
  --memberships $CLUSTER_NAME-membership \
  --project $PROJECT_ID