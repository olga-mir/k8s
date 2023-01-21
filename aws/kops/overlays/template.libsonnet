{
  k8sVersion: "1.23.14",
  clusterName: "<MY_CREATIVE_CLUSTER_NAME>.k8s.local",
  configBase: "s3://<KOPS_STATE_STORE_BUCKET>/<MY_CREATIVE_CLUSTER_NAME>.k8s.local",
  controlPlane: {
    image: "<IMAGE_FOR_CONTROL_PLANE>",
    machineType: "t3.medium",
  },
  nodePools: [
    {
      name: "default-ig",
      image: "IMAGE_FOR_WORKER_NODES",
      machineType: "t3.medium",
    }
  ]
}

