# Prerequisites

You needs access to AWS account with sufficient permissions to create a role for kOps, create cluster resources, upload to S3 bucket.
AWS access needs to be configured and bucket name stored in `STATE_STORE_BUCKET_NAME` env var.

* kOps
* jsonnet
* Makefile
* AWS CLI

Please check out [docs](../docs/setup.md) to configure the setup.

# Setup env

Create environment file with the following variables and providing your values:

```
export AWS_PROFILE=
export STATE_STORE_BUCKET_NAME=
export KOPS_STATE_STORE=s3://$STATE_STORE_BUCKET_NAME

export KOPS_CLUSTER_NAME=
export CONTROL_PLANE_IMAGE=
export WORKER_NODES_IMAGE=
```

`KOPS_STATE_STORE` and images will be ommitted later, but they are required for now.
`KOPS_CLUSTER_NAME` must be of form <NAME>.k8s.local, it is a variable which is used by kOps. This project doesn't rely on this variable and provides `name` explicitely. Using `KOPS_CLUSTER_NAME` to differentiate from other cluster deployments.
Other "reserved" env variables can be found in the [kops hack folder](https://github.com/kubernetes/kops/blob/b9c89c42a56318170a34f7986b4bf60a49a6cf4f/hack/update-expected.sh#L31)

source the env file:
```
$ . ./.setup-env
```

Optionally, generate your own overlay file. This file will be generated as part of `cluster.yaml` generation by the Makefile.

```
$ envsubst < kops/overlays/template.libsonnet > kops/overlays/dev-cluster.libsonnet
```

## Obtaining images

For more info check out kops documentation: https://github.com/kubernetes/kops/blob/master/docs/operations/images.md
Below is the command to find latest Amazon Linux 2023, which is at the moment experimental in kops.

```
aws ec2 describe-images --region $AWS_REGION --output table \
  --filters "Name=owner-alias,Values=amazon" \
  --query "sort_by(Images, &CreationDate)[*].[CreationDate,Name,ImageId]" \
  --filters "Name=name,Values=al2023-ami-2*-kernel-6.1-x86_64"
```

This setup is tested with latest image:
```
|  2023-10-23T19:05:45.000Z |  al2023-ami-2023.2.20231018.2-kernel-6.1-x86_64  |  ami-09b402d0a0d6b112b |
```

# Deploy

Cluster config is generated using jsonnet and then passed as one `cluster.yaml` file to kOps to create the cluster.

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
