{
  k8sVersion: "1.21.4",
  clusterName: "<MY_CREATIVE_CLUSTER_NAME>.k8s.local",
  configBase: "s3://<KOPS_STATE_STORE_BUCKET>/<MY_CREATIVE_CLUSTER_NAME>.k8s.local",
  controlPlane: {
    image: "<IMAGE_FOR_CONTROL_PLANE>",
    machineType: "t3.medium",
  },
  nodePools: [
    {
      name: "default-ig",
      image: "IMAGE_FOR_WORKER_NODES_CAN_BE_THE_SAME_AS_ABOVE",
      machineType: "t3.medium",
    }
  ]
}

