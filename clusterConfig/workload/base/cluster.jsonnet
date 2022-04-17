local cluster(env, ns, clusterNetworkCidr) =
{
  "apiVersion": "cluster.x-k8s.io/v1beta1",
  "kind": "Cluster",
  "metadata": {
    "name": env,
    "namespace": ns
  },
  "spec": {
    "clusterNetwork": {
      "pods": {
        "cidrBlocks": [
          clusterNetworkCidr
        ]
      }
    },
    "controlPlaneRef": {
      "apiVersion": "controlplane.cluster.x-k8s.io/v1beta1",
      "kind": "KubeadmControlPlane",
      "name": env + "-control-plane"
    },
    "infrastructureRef": {
      "apiVersion": "infrastructure.cluster.x-k8s.io/v1beta1",
      "kind": "AWSCluster",
      "name": env
    }
  }
};

cluster('staging', 'cluster-ns', '192.168.0.0/16')
