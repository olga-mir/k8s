#!/bin/bash

set -eoux pipefail

# https://www.cloudskillsboost.google/focuses/8459?parent=catalog

GKE_CLUSTER_NAME="asm-demo"
CLUSTER_VERSION="1.29.4-gke.1043002"
NODEPOOL_NAME="apps"

# ZONE must be set in env vars
if [ -z "$ZONE" ] || \
   [ -z "$CLUSTER_VPC" ] || \
   [ -z "$PROJECT_NUMBER" ] || \
   [ -z "$CLUSTER_SUBNET" ]; then
  echo "Error required env variables are not set" && exit 1
fi

gcloud projects get-iam-policy $PROJECT_ID \
    --flatten="bindings[].members" \
    --filter="bindings.members:user:$(gcloud config get-value core/account 2>/dev/null)"

gcloud services enable mesh.googleapis.com

MESH_ID="asm-mesh-1"
gcloud container clusters create $GKE_CLUSTER_NAME \
    --cluster-version=$CLUSTER_VERSION \
    --zone=$ZONE \
    --node-locations=$ZONE \
    --network=$CLUSTER_VPC \
    --subnetwork=$CLUSTER_SUBNET \
    --enable-dataplane-v2 \
    --workload-pool=${PROJECT_ID}.svc.id.goog \
    --workload-metadata=GKE_METADATA \
    --labels mesh_id=${PROJECT_NUMBER} \
    --logging=SYSTEM,WORKLOAD

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
    --total-max-nodes=2 \
    --machine-type=n2-standard-4 \
    --spot

gcloud container clusters get-credentials $GKE_CLUSTER_NAME --zone $ZONE --project $PROJECT_ID

#### --enable_all

# This CRB required even if the user already has admin via another binding:
# asmcli: [ERROR]: Current user must have the cluster-admin role on asm-demo.
# Please add the cluster role binding and retry, or run the script with the
# '--enable_cluster_roles' flag to allow the script to enable it on your behalf.
# Alternatively, use --enable_all|-e to allow this tool to handle all dependencies.
kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value core/account 2>/dev/null)

kubectl create ns istio-system
#### END --enable_all

# ASMCLI DOES NOT WORK ON MAC
# https://github.com/GoogleCloudPlatform/anthos-service-mesh-packages/issues/1182.
# These commands can be executed in Cloud Shell instead

# Download, chmod and move to local bin:
# curl https://storage.googleapis.com/csm-artifacts/asm/asmcli_1.21 > asmcli

# --output_dir must be absolute path
asmcli validate \
  --project_id $PROJECT_ID \
  --cluster_name $GKE_CLUSTER_NAME \
  --cluster_location $ZONE \
  --fleet_id $PROJECT_ID \
  --output_dir $(pwd)/asm_output_validate

asmcli install \
  --project_id $PROJECT_ID \
  --cluster_name $GKE_CLUSTER_NAME \
  --cluster_location $ZONE \
  --fleet_id $PROJECT_ID \
  --output_dir $(pwd)/asm_output_install \
  --option legacy-default-ingressgateway \
  --ca mesh_ca \
  --enable_gcp_components

  # --enable_all \

# $ k get po -A | grep -E "istio|asm"
# asm-system     canonical-service-controller-manager-74c6dc6698-nwwkb   2/2     Running   0          89s
# istio-system   istio-ingressgateway-f4984d45-2pw7h                     1/1     Running   0          114s
# istio-system   istio-ingressgateway-f4984d45-lvhb9                     1/1     Running   0          99s
# istio-system   istiod-asm-1207-2-5c69978f76-s9pp9                      1/1     Running   0          2m3s
# istio-system   istiod-asm-1207-2-5c69978f76-wrln8                      1/1     Running   0          107s

GATEWAY_NS=istio-gateway
kubectl create namespace $GATEWAY_NS

# Get and store revision:
REVISION=$(kubectl get deploy -n istio-system -l app=istiod -o \
jsonpath={.items[*].metadata.labels.'istio\.io\/rev'}'{"\n"}')

kubectl label namespace $GATEWAY_NS \
istio.io/rev=$REVISION --overwrite

# use your app namespace
kubectl label namespace default istio-injection=enabled
kubectl label namespace $GATEWAY_NS  istio-injection=enabled

# cd to install output
# kubectl apply -n $GATEWAY_NS -f samples/gateways/istio-ingressgateway

kubectl label namespace default istio-injection-istio.io/rev=$REVISION --overwrite

kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml

kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml

kubectl exec -it $(kubectl get pod -l app=ratings \
    -o jsonpath='{.items[0].metadata.name}') \
    -c ratings -- curl productpage:9080/productpage | grep -o "<title>.*</title>"

# sudo apt install siege

