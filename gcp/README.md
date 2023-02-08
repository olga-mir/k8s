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

Terraform code for one time setup is in `$REPO_ROOT/gcp/foundations` folder. At this time only network related code is available.
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

## Toolbox

Like admin container on AWS BottleRocket, GCP COS has `toolbox` many even basic things are missing there.

[source repo](https://cos.googlesource.com/cos/tools)
[google guide](https://cloud.google.com/container-optimized-os/docs/how-to/toolbox)

```
apt-get install tree
apt-get install less
apt install psmisc

# https://docs.cilium.io/en/latest/bpf/toolchain/
$ sudo apt-get install -y make gcc libssl-dev bc libelf-dev libcap-dev \
  clang gcc-multilib llvm libncurses5-dev git pkg-config libmnl-dev bison flex \
  graphviz

# bpf based performance tools.
# https://github.com/iovisor/bcc/blob/master/INSTALL.md
sudo apt-get install bpfcc-tools linux-headers-$(uname -r)
```
find where the isntalled tools are located: `dpkg -L  bpfcc-tools`

errors
```
E: Unable to locate package linux-headers-5.10.147
E: Couldn't find any package by glob 'linux-headers-5.10.147'
E: Couldn't find any package by regex 'linux-headers-5.10.147'
```
needs `linux-headers-5.10`, but then

```
$ /usr/sbin# ./execsnoop-bpfcc
modprobe: FATAL: Module kheaders not found in directory /lib/modules/5.10.147+
Unable to find kernel headers. Try rebuilding kernel with CONFIG_IKHEADERS=m (module) or installing the kernel development package for your running kernel version.
chdir(/lib/modules/5.10.147+/build): No such file or directory
Traceback (most recent call last):
  File "/usr/sbin/./execsnoop-bpfcc", line 227, in <module>
    b = BPF(text=bpf_text)
  File "/usr/lib/python3/dist-packages/bcc/__init__.py", line 364, in __init__
    raise Exception("Failed to compile BPF module %s" % (src_file or "<text>"))
Exception: Failed to compile BPF module <text>
```

## Debug IAP connections

gcloud compute ssh <NODE> --project=<PROJ> --zone=<ZONE> --troubleshoot
gcloud compute ssh <NODE> --project=<PROJ> --zone=<ZONE> --troubleshoot --tunnel-through-iap

