# k8s

This repository contains scripts and manifests to create a kubernetes cluster on AWS using kOps.
This cluster is intended to be short-lived and used for self learning. It is deployed to the default VPC into public subnets. SSH and API server access is allowed only from the same IP address that it was created from, therefore it is possible to get locked out if IP changes and will require restore via AWS UI. Some security features are intentionally omitted (like audit logging, appArmor, OPA, etc) to allow practcing and experimenting. Always delete when not in use.

# Prerequisites

You needs access to AWS account with sufficient permissions to create a role for kOps, create cluster resources, upload to S3 bucket.
AWS access needs to be configured and bucket name stored in `STATE_STORE_BUCKET_NAME` env var.

To validate basic setup run:
```sh
make check-setup
```

Tools: kOps, jsonnet, Makefile, AWS cli.
Please check out this [doc](docs/setup.md) configure the setup.

# Getting started

Cluster config is generated using jsonnet and then passed as one `cluster.yaml` file to kOps to create the cluster.
Start by providing cluster params such as name and kOps bucket by copying `clusterConfig/example-dev.libsonnet` to `clusterConfig/dev.libsonnet` and editing placeholder values.

Generate and inspect the `cluster.yaml`:
```
make cluster.yaml
```

Create cluster (it will generate cluster config if required):
```
make create-cluster
```

The above command also exports admin kubeconfig in default location.

Once done, don't forget to tear down to save moneyz and to avoid security risks - this cluster is not overly secure ;) 
```
make delete-cluster-yes
```
