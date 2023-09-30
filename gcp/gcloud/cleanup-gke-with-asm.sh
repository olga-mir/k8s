#!/bin/bash
set -eoux pipefail

# GKE cluster with managed ASM
# https://cloud.google.com/service-mesh/docs/unified-install/install-anthos-service-mesh-command#local-computer

if [ -z "$ZONE" ] || \
   [ -z "$PROJECT_ID" ] || \
   [ -z "$GKE_CLUSTER_NAME" ]; then
  echo "Error required env variables are not set" && exit 1
fi

CLUSTER_LOCATION=$ZONE

gcloud container clusters delete $GKE_CLUSTER_NAME --region $CLUSTER_LOCATION

# Deleting cluster only will leave membership and mesh feature in a broken state. e.g.

# Redacted snippets of orphaned resources

# % gcloud container fleet mesh describe
# membershipSpecs:
#   projects/<NUM>/locations/global/memberships/<GKE_CLUSTER_NAME>-membership:
#     mesh:
#       management: MANAGEMENT_AUTOMATIC
# membershipStates:
#   projects/<NUM>/locations/global/memberships/<GKE_CLUSTER_NAME>-membership:
#     state:
#       code: ERROR
#       description: GKE Cluster missing
#       updateTime: '<time>'

# % gcloud container fleet memberships describe <GKE_CLUSTER_NAME>-membership
# authority:
#   identityProvider: https://container.googleapis.com/v1/projects/<PROJECT_ID>/locations/<ZONE>/clusters/<GKE_CLUSTER_NAME>
#   issuer: https://container.googleapis.com/v1/projects/<PROJECT_ID>/locations/<ZONE>/clusters/<GKE_CLUSTER_NAME>
#   workloadIdentityPool: <my_pool>
# endpoint:
#   gkeCluster:
#     clusterMissing: true

gcloud container fleet mesh disable
gcloud container fleet memberships delete ${GKE_CLUSTER_NAME}-membership --quiet

