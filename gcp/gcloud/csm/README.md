# Cloud Service Mesh POC

aka trying to keep my sanity while figuring out the mess of `CSM`, `ASM`, `Traffic Director`, `Istiod APIs`, `Google APIs`.

## Terminology.

This mess stems from the organic growth of the services that they explained in the launch video in Google Next 24: https://cloud.withgoogle.com/next/session-library?session=OPS205#all

This is important to keep in mind to better understand these terms. `*CM` came from k8s world, while `Traffic Director` addressed somewhat similar concerns for other entities on the network which are not part of GKE.

They are now merged together as you can see at the banners at the top of any CSM page:

![ASM and Traffic Director are now CSM](./docs/images/td-and-csm.png "asm-and-td-is-csm")

But you'll still keep seeing TD through out the docs.

## POC Goal

Step 1:
Run GKE and Cloud Run inside the same mesh. Deploy an image to both runtimes and ping from one side to the other.

Step 2:
Once that miracle works I can think of more advanced scenarious.

## High Level Steps

### Initially my plan of attack was

1. Create GKE cluster with CSM enabled: https://cloud.google.com/service-mesh/docs/onboarding/provision-control-plane (I chose GKE on the left hand pane in navigation section "Onboard > Enable and provision service mesh", maybe GCE would have been the correct choice)
2. Deploy Cloud Run instance into said Mesh using this guide: https://cloud.google.com/service-mesh/docs/configure-cloud-service-mesh-for-cloud-run

Some snippets of this is stored in [./docs/what-not-to-do](./docs/what-not-to-do)
As you can guess from the folder's name this didn't go all too well.

I've tried to unwind this failure with [./move-gke-from-asm-to-csm.sh](./move-gke-from-asm-to-csm.sh) but ran out of time. 

### Plan for next attempt

1. Create CSM (Traffic Director) first: [./deploy-mesh.sh](./deploy-mesh.sh)
2. Create GKE Cluster, enrol in fleet, and enrol in the CSM
  a. my current understanding of adding a cluster to CSM (which is TD and not ASM) is by adding Zonal NEGs to the mesh.
3. Deploy Cloud Run [./deploy-cr.sh](./deploy-cr.sh)



To Be Continued...



## Instructions

To use scripts in this folder setup following variables (store them in a file and source):
```
export CLUSTER_NAME=""
export CLUSTER_VERSION="1.30.3-gke.1969001"
export CLUSTER_VPC=""
export CLUSTER_SUBNET=""
export CR_SUBNET_NAME=""
export NODEPOOL_NAME=""
export ZONE=""
export REGION=""
export MESH_NAME=""
export PROJECT_ID=""
export PROJECT_NUMBER=""

export MEMBERSHIP_LOCATION=$REGION
export MEMBERSHIP_NAME=$CLUSTER_NAME
export CR_VPC_NAME=$CLUSTER_VPC
export FLEET_PROJECT_ID=$PROJECT_ID
```

Create `manifests/rendered` folder to store rendered manifests.
