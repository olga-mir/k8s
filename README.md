# k8s

This repository contains scripts and manifests to create a kubernetes cluster on AWS using kOps.
This cluster is intended to be short-lived and used for self learning. It is deployed to the default VPC into public subnets. SSH and API server access is allowed only from the same IP address that it was created from, therefore it is possible to get locked out if IP changes and will require restore via AWS UI. Some security features are intentionally omitted (like audit logging, appArmor, OPA, etc) to allow practcing and experimenting. Always delete when not in use.

# Supported Versions

This setup has been tested with kubernetes version 1.23.14 and kOps version 1.25.3

# Prerequisites

You needs access to AWS account with sufficient permissions to create a role for kOps, create cluster resources, upload to S3 bucket.
AWS access needs to be configured and bucket name stored in `STATE_STORE_BUCKET_NAME` env var.

Tools: kOps, jsonnet, Makefile, AWS cli.
Please check out this [doc](docs/setup.md) configure the setup.

# Getting started

Cluster config is generated using jsonnet and then passed as one `cluster.yaml` file to kOps to create the cluster.
Start by providing cluster params such as name and kOps bucket by copying `clusterConfig/mgmt/overlays/template.libsonnet` to `clusterConfig/mgmt/overlays/mgmt.libsonnet` and editing placeholder values.

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

# Cluster API and Flux

Demo provisioning management cluster (in bootstrap and pivot pattern) with workload clusters that are synced by Flux is available in my other repo: https://github.com/olga-mir/k8s-multi-cluster
These are AWS clusters (not EKS) running Cilium in kube-proxy-free mode, with cluster-mesh coming soon.

```
% k get cluster -A
NAMESPACE      NAME           PHASE          AGE   VERSION
cluster-01     cluster-01     Provisioned    12m
cluster-02     cluster-02     Provisioning   60s
cluster-mgmt   cluster-mgmt   Provisioned    13m
```
