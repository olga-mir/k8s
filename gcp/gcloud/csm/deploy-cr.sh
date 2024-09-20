#!/bin/bash

set -eoux pipefail

# https://cloud.google.com/service-mesh/docs/configure-cloud-service-mesh-for-cloud-run

# Validate that required variables are defined
: "${MESH_NAME:?Variable MESH_NAME is not set}"
: "${CLUSTER_NAME:?Variable CLUSTER_NAME is not set}"
: "${REGION:?Variable REGION is not set}"
: "${DESTINATION_SERVICE_NAME:?Variable DESTINATION_SERVICE_NAME is not set}"
: "${PROJECT_ID:?Variable PROJECT_ID is not set}"
: "${PROJECT_NUMBER:?Variable PROJECT_NUMBER is not set}"
: "${VPC_NETWORK_NAME:?Variable VPC_NETWORK_NAME is not set}"
: "${CR_SUBNET_NAME:?Variable CR_SUBNET_NAME is not set}"
: "${DOMAIN_NAME:?Variable DOMAIN_NAME is not set}"

"${IMAGE_URL:-us-docker.pkg.dev/cloudrun/container/hello:latest}"
"${CLIENT_SERVICE_NAME:-csm-cr-client}"
"${DOMAIN_NAME:-csm-dns.com}"
exit 0

# Make sure you run mesh create before this script
# MESH_NAME=$(gcloud network-services meshes list --location=global --format=json | yq '.[0].name')

# Setup Cloud DNS
gcloud dns managed-zones create ${MESH_NAME} \
  --description="Domain for ${DOMAIN_NAME} service mesh routes" \
  --dns-name=${DOMAIN_NAME}. \
  --network=${VPC_NETWORK_NAME} \
  --visibility=private

gcloud dns record-sets create "*.$DOMAIN_NAME." \
  --type=A \
  --zone=$MESH_NAME \
  --rrdatas=10.0.0.1 \
  --ttl=3600


gcloud run deploy $DESTINATION_SERVICE_NAME \
  --no-allow-unauthenticated \
  --region=$REGION \
  --image=$IMAGE_URL

gcloud compute network-endpoint-groups create destination-neg \
  --region=$REGION \
  --network-endpoint-type=serverless \
  --cloud-run-service=$DESTINATION_SERVICE_NAME

# 2
# Create an internal self-managed backend service that references the serverless NEG.

# 2a.
gcloud compute backend-services create ${DESTINATION_SERVICE_NAME-$REGION} \
  --global \
  --load-balancing-scheme="INTERNAL_SELF_MANAGED"

# 2b.
gcloud compute backend-services add-backend ${DESTINATION_SERVICE_NAME}-${REGION} \
  --global \
  --network-endpoint-group=destination-neg \
  --network-endpoint-group-region=$REGION

# 3 - Create an HTTP route that references the backend service.
# 3a.
# TODO - manifest
envsubst < manifests/templates/cr_http_route.yaml > manifests/rendered/http_route.yaml

gcloud network-services http-routes import ${DESTINATION_SERVICE_NAME}-route \
  --source=manifests/rendered/http_route.yaml \
  --location=global

gcloud run services add-iam-policy-binding $DESTINATION_SERVICE_NAME \
  --member=serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com \
  --role=roles/run.invoker \
  --region=$REGION

# Create Client
# https://cloud.google.com/service-mesh/docs/configure-cloud-service-mesh-for-cloud-run#client
gcloud beta run deploy $CLIENT_SERVICE_NAME \
  --region=$REGION \
  --image=fortio/fortio \
  --network=$VPC_NETWORK_NAME \
  --subnet=$CR_SUBNET_NAME \
  --mesh="projects/$PROJECT_ID/locations/global/meshes/$MESH_NAME"

TEST_SERVICE_URL=$(gcloud run services describe $CLIENT_SERVICE_NAME \
  --region=$REGION --format="value(status.url)" \
  --project=$PROJECT_ID)

# Send a test request
curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" "$TEST_SERVICE_URL/fortio/fetch/$DESTINATION_SERVICE_NAME.$DOMAIN_NAME"

