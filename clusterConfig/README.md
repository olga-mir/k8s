# Clusters Config

This folder contains jsonnet configs for CAPI management cluster and workload cluster(s)

It has been written by a complete jsonnet n00b (me) with heavy influence of kustomize patterns (hence for example 'base' and 'overlays' folders)

## Folder Structure

```
├── README.md
├── mgmt   # kops on AWS cluster config in jsonnet format
│   ├── base
│   │   ├── cluster.jsonnet
│   │   ├── controlPlaneNodeGroup.jsonnet
│   │   └── workerNodeGroup.jsonnet
│   └── overlays
│       ├── mgmt.libsonnet       # instance of the template filled with values specific to env (not committed to repo)
│       └── template.libsonnet   # example input param template
└── workload
    ├── base
    ├── prod
    ├── staging
    └── template-init
```

## Management Cluster

Management cluster is a kops cluster provisioned on AWS

## Workload Clusters

### Initialization of Workload Cluster Configs

This is semi-manual procedure which is done once to produce jsonnet files for future workload clusters generation

1. When management cluster is up and running, generate basic workload cluster:

```
clusterctl generate cluster templatecluster --kubernetes-version v1.22.8 --control-plane-machine-count=1 --worker-machine-count=1 > templatecluster.yaml
```
2. Split `templatecluster.yaml` into a json file per resource.
`templatecluster.yaml` contains a few resources and there is no straight forward conversion to a valid json that is easy to transform to jsonnet file. I find it easier to understand when each resource is in its own file.
From the root of the repo run:
```
./scripts/yaml2json-converter.sh templatecluster.yaml clusterConfig/workload/template-init
```

Next bit is manual. Every file in template-init directory


### Notes
https://github.com/kubecfg/kubecfg ?


