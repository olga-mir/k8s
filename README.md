# k8s

This repository contains scripts and manifests to create a kubernetes cluster on AWS using kops.
This cluster is intended to be short-lived and used for self learning. 

# Prerequisites

You needs access to AWS account with sufficient permissions to create a role for kops, create cluster resources, upload to an S3 bucket.
AWS access needs to be configured and bucket name stored in `STATE_STORE_BUCKET_NAME` env var.

To validate basic setup run:
```sh
make check-setup
```

Tools: kops, jsonnet, Makefile, AWS cli.
Please check out this [doc](docs/setup.md) configure the setup.

# Getting started

Cluster config is generated using jsonnet and then passed as one `cluster.yaml` file to kops to create the cluster.
Start by providing cluster params such as name and kops bucket by copying `clusterConfig/example-dev.libsonnet` to `clusterConfig/dev.libsonnet` and editing placeholder values.

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
