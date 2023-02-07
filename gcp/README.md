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


## Toolbox

Like admin container on AWS BottleRocket, GCP COS has `toolbox` many even basic things are missing there.

```
apt-get install tree
apt-get install less
apt-get install ps
apt install psmisc

# https://docs.cilium.io/en/latest/bpf/toolchain/
$ sudo apt-get install -y make gcc libssl-dev bc libelf-dev libcap-dev \
  clang gcc-multilib llvm libncurses5-dev git pkg-config libmnl-dev bison flex \
  graphviz

# bpf based performance tools.
echo deb http://cloudfront.debian.net/debian sid main >> /etc/apt/sources.list
sudo apt-get install -y bpfcc-tools libbpfcc libbpfcc-dev linux-headers-$(uname -r)
```

## Debug IAP connections

gcloud compute ssh <NODE> --project=<PROJ> --zone=<ZONE> --troubleshoot
gcloud compute ssh <NODE> --project=<PROJ> --zone=<ZONE> --troubleshoot --tunnel-through-iap

