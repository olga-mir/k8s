local settings = import '../overlays/dev-cluster.libsonnet';

{
  "apiVersion": "kops.k8s.io/v1alpha2",
  "kind": "InstanceGroup",
  "metadata": {
    "labels": {
      "kops.k8s.io/cluster": settings.clusterName,
    },
    "name": settings.nodePools[0].name,
  },
  "spec": {
    "machineType": settings.nodePools[0].machineType,
    "maxSize": 3,
    "minSize": 2,
    "nodeLabels": {
      "kops.k8s.io/instancegroup": settings.nodePools[0].name,
    },
    "role": "Node",
    "subnets": [
      "ap-southeast-2a"
    ]
  }
}
