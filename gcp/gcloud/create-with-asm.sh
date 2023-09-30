#!/bin/bash
set -eoux pipefail

# GKE cluster with managed ASM
# https://cloud.google.com/service-mesh/docs/unified-install/install-anthos-service-mesh-command#local-computer

# ZONE must be set in env vars
if [ -z "$ZONE" ] || \
   [ -z "$CLUSTER_VPC" ] || \
   [ -z "$PROJECT_ID" ] || \
   [ -z "$PROJECT_NUMBER" ] || \
   [ -z "$GKE_CLUSTER_NAME" ] || \
   [ -z "$SUBNET_DEV" ]; then
  echo "Error required env variables are not set" && exit 1
fi

CLUSTER_VERSION="1.27.3-gke.1700"
NODEPOOL_NAME="apps"
MACHINE_TYPE="e2-standard-4"
CLUSTER_LOCATION=$ZONE

# there is no way in `gcloud` to create a cluster without default nodepool
gcloud container clusters create $GKE_CLUSTER_NAME \
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
    --cluster=$GKE_CLUSTER_NAME \
    --zone=$ZONE \
    --quiet

gcloud container node-pools create $NODEPOOL_NAME \
    --cluster=$GKE_CLUSTER_NAME \
    --zone=$ZONE \
    --node-locations=$ZONE \
    --location-policy=BALANCED \
    --enable-autoscaling \
    --machine-type=$MACHINE_TYPE \
    --spot

gcloud container fleet mesh enable --project $PROJECT_ID

gcloud container fleet memberships register $GKE_CLUSTER_NAME-membership \
  --gke-cluster=$CLUSTER_LOCATION/$GKE_CLUSTER_NAME \
  --enable-workload-identity \
  --project $PROJECT_ID

gcloud container fleet mesh update \
  --management automatic \
  --memberships $GKE_CLUSTER_NAME-membership \
  --project $PROJECT_ID


echo "It can take about 10 minutes for Anthos Service Mesh to provision and be ready to use on the cluster."
echo "Pause for 5mi before testing the status. You can run following command to check the progress:"
echo "gcloud container fleet mesh describe --project $PROJECT_ID | yq '.membershipStates[] | {"controlPlane": .servicemesh.controlPlaneManagement.state, "dataPlane": .servicemesh.dataPlaneManagement.state}'"

sleep 300
retries=15

while [[ $retries > 0 ]] && asm_cp=$(gcloud container fleet mesh describe --project $PROJECT_ID | yq '.membershipStates[] | .servicemesh.controlPlaneManagement.state') && [ $asm_cp != "ACTIVE" ] ; do
  echo $(date '+%F %H:%M:%S') Controlplane status $asm_cp. Re-try in 30s... && retries=$((retries-1)) && sleep 30
done

# Dataplane should be ready soon after the Controlplane is already running

while [[ $retries > 0 ]] && asm_dp=$(gcloud container fleet mesh describe --project $PROJECT_ID | yq '.membershipStates[] | .servicemesh.dataPlaneManagement.state') && [ $asm_dp != "ACTIVE" ] ; do
  echo $(date '+%F %H:%M:%S') Dataplane status $asm_dp. Re-try in 15s... && retries=$((retries-1)) && sleep 15
done

# Redacted sample output:

# % gcloud container fleet mesh describe --project $PROJECT_ID
# createTime: '<time>'
# membershipSpecs:
#   projects/<PROJECT_NUM>/locations/global/memberships/<GKE_CLUSTER_NAME>-membership:
#     mesh:
#       management: MANAGEMENT_AUTOMATIC
# membershipStates:
#   projects/<PROJECT_NUM>/locations/global/memberships/<GKE_CLUSTER_NAME>-membership:
#     servicemesh:
#       controlPlaneManagement:
#         details:
#           - code: REVISION_READY
#             details: 'Ready: asm-managed-stable'
#         state: ACTIVE
#       dataPlaneManagement:
#         details:
#           - code: OK
#             details: Service is running.
#         state: ACTIVE
#     state:
#       code: OK
#       description: 'Revision(s) ready for use: asm-managed-stable.'
#       updateTime: '<time>'
# name: projects/<PROJECT_ID>/locations/global/features/servicemesh
# resourceState:
#   state: ACTIVE
