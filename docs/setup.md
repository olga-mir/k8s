# Prerequisites

Access to AWS account with [enough privileges](aws/iam.yaml)
The minimal default cluster consists of 1 master and 1 worker node, with configurable instance size; it's easy to setup and tear down the cluster so the charges are minimal.
Kops stores the state as a file in S3, if using versioning this can accumulate a little cost over time.

# Setup

## kops

To install kops [latest release](https://github.com/kubernetes/kops/releases/latest)
```
brew install kops
```

Alternatively, to install bleeding edge pre-released kops use specific version (https://github.com/kubernetes/kops/releases), for example:

```sh
TAG=v1.18.0-alpha.2
curl -Lo kops https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/tags/${TAG} | grep tag_name | cut -d '"' -f 4)/kops-darwin-amd64
chmod +x ./kops
sudo mv ./kops /usr/local/bin/
```

## jsonnet

jsonnet is a data templating language, check out github [repo](https://github.com/google/jsonnet) and their docs.

install:
```
brew install jsonnet
```

## yq, jq and friends

If you haven't already

# Once off setup

S3 bucket and IAM settings do not need to be destroyed each time.

```sh
make kops-iam
```
Or follow [kops guide](https://kops.sigs.k8s.io/getting_started/aws/#setup-iam-user)

Create bucket for kops to store the state. The bucket content is emptied on cluster deletion.
```sh
make create-cluster-store-bucket
```

# Create cluster

Create cluster hands-off:

```sh
make create-cluster
```

This will create state, upload it to s3, instruct kOps to create the cluster and download cluster-admin auth credentials.
Note that if there is existing kubeconfig, then it will be merged with settings for the new cluster

# Delete cluster
```sh
make delete-cluster-yes
```

### Notes
To create cluster config:
`kops create cluster --zones ap-southeast-2a --container-runtime=containerd --networking=calico --dry-run -oyaml`
then export from existing cluster:
`kops get cluster --name $KOPS_CLUSTER_NAME -o yaml > cluster.yaml`
docs: https://kops.sigs.k8s.io/manifests_and_customizing_via_api/
