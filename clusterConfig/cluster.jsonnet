local settings = import 'dev.libsonnet';

local ssh_ip_cidr = std.extVar('ssh_ip_cidr');

{
  "apiVersion": "kops.k8s.io/v1alpha2",
  "kind": "Cluster",
  "metadata": {
    "name": settings.clusterName,
  },
  "spec": {
    "api": {
      "loadBalancer": {
        "class": "Classic",
        "type": "Public"
      }
    },
    "authorization": {
      "rbac": {}
    },
    "channel": "stable",
    "cloudProvider": "aws",
    "configBase": settings.configBase,
    "containerRuntime": "containerd",
    "etcdClusters": [
      {
        "cpuRequest": "200m",
        "etcdMembers": [
          {
            "instanceGroup": "master-ap-southeast-2a",
            "name": "a"
          }
        ],
        "memoryRequest": "100Mi",
        "name": "main"
      },
      {
        "cpuRequest": "100m",
        "etcdMembers": [
          {
            "instanceGroup": "master-ap-southeast-2a",
            "name": "a"
          }
        ],
        "memoryRequest": "100Mi",
        "name": "events"
      }
    ],
    "iam": {
      "allowContainerRegistry": true,
      "legacy": false,
      "spec": null
    },
    "kubeAPIServer": {
      "enableAdmissionPlugins": [
        "PodSecurityPolicy"
      ],
      "disableBasicAuth": true
    },
    "kubelet": {
      "anonymousAuth": false
    },
    "kubernetesApiAccess": [
      "0.0.0.0/0"
    ],
    "kubernetesVersion": settings.k8sVersion,
    "masterPublicName": settings.clusterName,
    "networkCIDR": "172.20.0.0/16",
    "networking": {
      "calico": {
        "majorVersion": "v3"
      }
    },
    "nonMasqueradeCIDR": "100.64.0.0/10",
    "sshAccess": [
       ssh_ip_cidr
    ],
    "sshKeyName": "cks",
    "subnets": [
      {
        "cidr": "172.20.32.0/19",
        "name": "ap-southeast-2a",
        "type": "Public",
        "zone": "ap-southeast-2a"
      }
    ],
    "topology": {
      "dns": {
        "type": "Public"
      },
      "masters": "public",
      "nodes": "public"
    }
  }
}
