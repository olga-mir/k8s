# About

Scripts to create a GKE cluster with `gcloud` command.

Terraform provider doesn't support latest features, e.g. at this stage it is not possible to create a cgroupv2 cluster while it is possible with gcloud: https://cloud.google.com/kubernetes-engine/docs/how-to/node-system-config#cgroup-mode-options

# Setup

Access to GCP resources with significant permissions to create GKE clusters and enable APIs and features is required, but outside of the scope of this repo.

Setup env vars. Create a setup file and `source` in the working terminal session.
```
export PROJECT_NUMBER=
export PROJECT_ID=
export CLUSTER_NAME=

# this is not shared VPC model
export CLUSTER_VPC=
export ZONE=
export SUBNET_DEV=
```

# Options

## Multi Network for Pods

script: [./create-multi-network.sh](./create-multi-network.sh)

documentation: https://cloud.google.com/kubernetes-engine/docs/how-to/setup-multinetwork-support-for-pods

In addtion to general variables described in previous section, you'll need additional VPC to test the feature:

```
export HIGHPERF_VPC=
export SUBNET_HIGHPERF=
export HIGHPERF_SEC_RANGE=
```

## GKE with Fully Managed ASM

script: [./create-with-asm.sh](./create-with-asm.sh)
deploy demo app: [./deploy-asm-demo-app.sh](./deploy-asm-demo-app.sh)

docuementation: https://cloud.google.com/service-mesh/docs/unified-install/install-anthos-service-mesh-command

Note that to cleanup this setup it is not enough to just delete the cluster. More details in [./cleanup-gke-with-asm.sh](./cleanup-gke-with-asm.sh)
