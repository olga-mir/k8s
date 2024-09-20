#!/bin/bash

set -eoux pipefail

# Hopefully this is the guide I need:
# https://cloud.google.com/service-mesh/docs/onboarding/provision-control-plane
# https://github.com/GoogleCloudPlatform/microservices-demo/blob/main/kustomize/components/service-mesh-istio/README.md

# Validate that required variables are defined
: "${MESH_NAME:?Variable MESH_NAME is not set}"
: "${CLUSTER_NAME:?Variable CLUSTER_NAME is not set}"
: "${REGION:?Variable REGION is not set}"
: "${PROJECT_ID:?Variable PROJECT_ID is not set}"
: "${PROJECT_NUMBER:?Variable PROJECT_NUMBER is not set}"
: "${VPC_NETWORK_NAME:?Variable VPC_NETWORK_NAME is not set}"
: "${CLUSTER_SUBNET:?Variable SUBNET_NAME is not set}"

export FLEET_PROJECT_ID=$PROJECT_ID
export MEMBERSHIP_LOCATION=$REGION
export MEMBERSHIP_NAME=$CLUSTER_NAME

gcloud container clusters create $CLUSTER_NAME \
    --cluster-version=$CLUSTER_VERSION \
    --enable-dataplane-v2 \
    --enable-ip-alias \
    --network=$CLUSTER_VPC \
    --subnetwork=$CLUSTER_SUBNET \
    --node-locations=$ZONE \
    --disk-size=50GB \
    --total-max-nodes=4 \
    --workload-pool=${PROJECT_ID}.svc.id.goog \
    --workload-metadata=GKE_METADATA \
    --gateway-api=standard \
    --enable-fleet

gcloud container node-pools delete default-pool \
    --cluster=$CLUSTER_NAME \
    --region=australia-southeast1 \
    --quiet &

gcloud container node-pools create $NODEPOOL_NAME \
    --cluster=$CLUSTER_NAME \
    --region=$REGION \
    --location-policy=BALANCED \
    --enable-autoscaling \
    --total-max-nodes=4 \
    --machine-type=e2-standard-4 \
    --spot

gcloud container fleet memberships list --project $FLEET_PROJECT_ID

gcloud container fleet mesh update \
     --management automatic \
     --memberships $MEMBERSHIP_NAME \
     --project $FLEET_PROJECT_ID \
     --location $MEMBERSHIP_LOCATION

gcloud container fleet mesh describe --project $FLEET_PROJECT_ID
