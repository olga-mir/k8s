local settings = import 'dev.libsonnet';

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
    "image": settings.nodePools[0].image,
    "machineType": settings.nodePools[0].machineType,
    "maxSize": 1,
    "minSize": 1,
    "nodeLabels": {
      "kops.k8s.io/instancegroup": settings.nodePools[0].name,
    },
    "role": "Node",
    "subnets": [
      "ap-southeast-2a"
    ]
  }
}
