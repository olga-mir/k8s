local settings = import 'dev.libsonnet';

{
  "apiVersion": "kops.k8s.io/v1alpha2",
  "kind": "InstanceGroup",
  "metadata": {
    "labels": {
      "kops.k8s.io/cluster": settings.clusterName
    },
    "name": "master-ap-southeast-2a"
  },
  "spec": {
    "image": settings.controlPlane.image,
    "machineType": settings.controlPlane.machineType,
    "maxSize": 1,
    "minSize": 1,
    "nodeLabels": {
      "kops.k8s.io/instancegroup": "master"
    },
    "role": "Master",
    "subnets": [
      "ap-southeast-2a"
    ]
  }
}
