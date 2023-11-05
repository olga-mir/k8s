# k8s

This repository contains scripts, manifests and IaC to create standalone k8s clusters on AWS and GCP. For Cluster Mesh and Cluster API clusters check out [olga-mir/k8s-multi-cluster](https://github.com/olga-mir/k8s-multi-cluster)

The clusters are intended for learning and exploration.

These clusters are not hardened for security, primarily for lack of time and the fact that they are short-lived, bootstrapped in learning projects with hard limits. Nodes and API server are exposed with public IP. But SSH and API server access is allowed only from the same IP address that it was created from

# Supported Versions

* AWS (kOps): k8s - 1.28.3; kOps - 1.28.0
* AWS (EKS): k8s - 1.27, eksctl - 0.164.0
* GCP (GKE): k8s - 1.23.13

# Repository Structure

```
.
├── LICENSE
├── README.md
├── aws
│   ├── Makefile
│   ├── Makefile.preflight
│   ├── README.md
│   ├── eksctl      // EKS cluster with `eksctl`
│   ├── foundation  // network and IAM
│   └── kops        // AWS non-EKS cluster
├── docs
│   └── setup.md    // Tools setup and general info
├── gcp
│   ├── README.md
│   ├── crossplane          // TODO
│   ├── gcloud              // Create GKE cluster with `gcloud`
│   ├── multi-network-pods  // https://cloud.google.com/kubernetes-engine/docs/how-to/setup-multinetwork-support-for-pods
│   └── terraform           // Create GKE cluster with terraform
└── scripts         // Mostly scripts to install tools on nodes for debug, low level Linux digging, performance engineering and eBPF
```

Both GCP and AWS folders contain static resources (VPC, IAM, Buckets) that usually don't require cleanup because they don't incur any cost.
Beware that VPC stacks may include NATs or other resources that do incur cost and therefore have to be cleaned after each session

# AWS

Detailed instructions provided in [./aws/README.md](./aws/README.md)

## kOps

Tech: kOps, jsonnet, Makefile, aws cli

```
make kops-create-cluster
```

Cleanup:
```
make kops-delete-cluster-yes
```

## EKS (with `eksctl`)

tech: `eksctl`, aws cli, cloudformation

deploy: [./aws/eksctl/create.sh](./aws/eksctl/create.sh)
cleanup: [./aws/eksctl/cleanup.sh](./aws/eksctl/cleanup.sh)


# GCP (GKE)

## Prerequisites

* glcoud
* terraform
* Makefile

## Deploy

:warning: The following commands are meant to be run from `./gcp` directory.

Currently not all variables have been abstracted away and the tf code has hardcoded values for my VPC, but it does create a valid GKE cluster when these values are set correctly.

```
cd gcp/terraform
envsubst < foundation/template-tfvars > foundation/dev.tfvars
envsubst < template-tfvars > dev.tfvars
```

To create a VPC (only needed once):
```
make create-vpc
```

To create a cluster:

```
make create-gke
```
This will create tf plan if it doesn't exist or if dependencies changed

To delete the cluster:
```
make cleanup
```

To delete the cluster and supporting resources:
```
make full-cleanup
```


# Cluster API and GitOps with Flux

Demo provisioning management cluster (in bootstrap and pivot pattern) with workload clusters that are synced by Flux is available in my other repo: https://github.com/olga-mir/k8s-multi-cluster
These are AWS clusters (not EKS) running Cilium in kube-proxy-free mode, with cluster-mesh coming soon.

```
% k get cluster -A
NAMESPACE      NAME           PHASE          AGE   VERSION
cluster-01     cluster-01     Provisioned    12m
cluster-02     cluster-02     Provisioning   60s
cluster-mgmt   cluster-mgmt   Provisioned    13m
```
