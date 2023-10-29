{
  k8sVersion: "1.28.3",
  clusterName: "$KOPS_CLUSTER_NAME",
  configBase: "s3://${STATE_STORE_BUCKET_NAME}/${KOPS_CLUSTER_NAME}.k8s.local",
  controlPlane: {
    image: "$CONTROL_PLANE_IMAGE",
    machineType: "t3.medium",
  },
  nodePools: [
    {
      name: "default-ig",
      image: "$WORKER_NODES_IMAGE",
      machineType: "t3.medium",
    }
  ]
}

