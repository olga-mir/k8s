#!/bin/bash

This disables Anthos Service Mesh management that I currently have
gcloud container fleet mesh update \
  --management manual \
  --memberships $MEMBERSHIP_NAME \
  --project $FLEET_PROJECT_ID

gcloud compute network-endpoint-groups create gke-service-neg \
  --network-endpoint-type=gce-vm-ip-port \
  --zone=$ZONE \
  --subnet=$CLUSTER_SUBNET \
  --network=$CLUSTER_VPC

gcloud compute backend-services create gke-backend \
  --global \
  --load-balancing-scheme=INTERNAL_SELF_MANAGED

gcloud compute health-checks create http my-health-check \
  --port=80 \
  --request-path="/health"

gcloud compute backend-services add-backend gke-backend \
  --global \
  --network-endpoint-group=$REGION \
  --network-endpoint-group-zone=$ZONE

# ERROR: (gcloud.compute.backend-services.add-backend) Could not fetch resource:
# - Invalid value for field 'resource.healthChecks': ''. At least one health check needs to be specified.
#
# There is no healthchecks!!!! https://cloud.google.com/sdk/gcloud/reference/compute/backend-services/add-backend


