# GKE cluster


## Toolbox


```
apt-get install tree
apt-get install less
apt-get install ps
apt install psmisc

# https://docs.cilium.io/en/latest/bpf/toolchain/
$ sudo apt-get install -y make gcc libssl-dev bc libelf-dev libcap-dev \
  clang gcc-multilib llvm libncurses5-dev git pkg-config libmnl-dev bison flex \
  graphviz
```

## Debug IAP connections

gcloud compute ssh <NODE> --project=<PROJ> --zone=<ZONE> --troubleshoot
gcloud compute ssh <NODE> --project=<PROJ> --zone=<ZONE> --troubleshoot --tunnel-through-iap

