# GKE cluster

## Init

Setup env variables, then generate tfvar files using `envsubst`

```
GCP_PROJECT
GCP_REGION
GCP_NETWORK_NAME
GKE_CLUSTER_NAME
```

Run:

```
$ envsubst < foundation/template-tfvars > foundation/dev.tfvars
$ envsubst < template-tfvars > dev.tfvars
```

## Project and VPC

Terraform code for one time setup is in `$REPO_ROOT/gcp/terraform/foundations` folder. At this time only network related code is available.
```
make create-vpc
```

Required APIs:
```
"compute.googleapis.com",
"iam.googleapis.com",
"container.googleapis.com",
"iap.googleapis.com", # SSH to VMs via IAP
"networkmanagement.googleapis.com", # troubleshoot IAP connections
"cloudprofiler.googleapis.com",
```

## GKE Cluster

Create a cluster:
```
make create-gke
```

Delete the cluster:
```
make cleanup
```

## Toolbox and BPF tools

Using `toolbox` container on the VM:

[source repo](https://cos.googlesource.com/cos/tools)

[google guide](https://cloud.google.com/container-optimized-os/docs/how-to/toolbox)

Install BPF tools on GKE COS: [scripts/install-bpf-tools.sh](../scripts/install-bpf-tools.sh)


## Debug IAP connections

```
gcloud compute ssh <NODE> --project=<PROJ> --zone=<ZONE> --troubleshoot
gcloud compute ssh <NODE> --project=<PROJ> --zone=<ZONE> --troubleshoot --tunnel-through-iap
```

