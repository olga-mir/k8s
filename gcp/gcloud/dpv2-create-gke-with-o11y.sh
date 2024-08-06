#!/bin/bash

set -eoux pipefail

GKE_CLUSTER_NAME="gke-dpv2"
CLUSTER_VERSION="1.29.6-gke.1038001"
NODEPOOL_NAME="apps"

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
    --enable-dataplane-v2-flow-observability \
    --enable-dataplane-v2-metrics \
    --enable-managed-prometheus \
    --workload-pool=${PROJECT_ID}.svc.id.goog \
    --workload-metadata=GKE_METADATA

#    https://cloud.google.com/sdk/gcloud/reference/container/clusters/create#--workload-metadata

# this command can't run in background because there is not enough quota
gcloud container node-pools delete default-pool \
    --cluster=$GKE_CLUSTER_NAME \
    --zone=$ZONE \
    --quiet

gcloud container node-pools create $NODEPOOL_NAME \
    --cluster=$GKE_CLUSTER_NAME \
    --zone=$ZONE \
    --node-locations=$ZONE \
    --location-policy=BALANCED \
    --enable-autoscaling \
    --total-max-nodes=1 \
    --machine-type=e2-highcpu-4 \
    --spot 

gcloud container clusters get-credentials $GKE_CLUSTER_NAME --zone $ZONE --project $PROJECT_ID

sleep 60

kubectl apply -f dpv2-hubble-ui-std.yaml
# kubectl -n gke-managed-dpv2-observability port-forward service/hubble-ui 16100:80 --address='0.0.0.0'

PROM_VERSION="v0.12.0"
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/prometheus-engine/$PROM_VERSION/manifests/setup.yaml
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/prometheus-engine/$PROM_VERSION/manifests/operator.yaml
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/prometheus-engine/$PROM_VERSION/manifests/rule-evaluator.yaml
kubectl apply -f dpv2-pod-monitoring.yaml
