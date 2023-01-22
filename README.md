# k8s

This repository contains scripts and manifests to create a kubernetes cluster on AWS using kOps or GKE cluster using terraform.

The clusters are intended for learning and exploration. They are meant to be short-lived and cleanup Make targets are availble to easily dispose of them.

AWS cluster is deployed to the default VPC into public subnets. SSH and API server access is allowed only from the same IP address that it was created from, therefore it is possible to get locked out if IP changes and will require restore via web console.

These clusters are not hardened for security, primarily for lack of time and the fact that they are only up for short periods of time.

# Supported Versions

AWS: tested with kubernetes 1.23.14 and kOps 1.25.3
GCP: tested with GKE 1.23.13

# Prerequisites

You needs access to AWS account with sufficient permissions to create a role for kOps, create cluster resources, upload to S3 bucket.
AWS access needs to be configured and bucket name stored in `STATE_STORE_BUCKET_NAME` env var.

Tools: kOps, jsonnet, Makefile, AWS cli.
Please check out this [doc](docs/setup.md) configure the setup.

# AWS Cluster (not EKS)

Cluster config is generated using jsonnet and then passed as one `cluster.yaml` file to kOps to create the cluster.
Start by providing cluster params such as name and kOps bucket by copying `aws/kops/overlays/template.libsonnet` to `aws/kops/overlays/dev-cluster.libsonnet` and editing placeholder values.

Generate and inspect the `cluster.yaml`:
```
make cluster.yaml
```

Create cluster (it will generate cluster config if required) and export kubeconfig in default location:
```
make create-cluster
```

Cleanup:
```
make delete-cluster-yes
```

# GKE Cluster

Currently not all variables have been abstracted away and the tf code has hardcoded values for my VPC, but it does create a valid GKE cluster when these values are set correctly.

```
cd gcp
cp template.tfvars dev.tfvars
```

Provide your values in `dev.tfvars` vars file.

As this is a short lived cluster that is designed to be deleted at the end of learning session, there is no point in keeping tf plan in persistent storage, therefore it is stored locally in the same directory.
To create a cluster:

```
make tf-apply
```
This will create tf plan if it doesn't exist or if dependencies changed

To delete the cluster and other resources:
```
make cleanup
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
