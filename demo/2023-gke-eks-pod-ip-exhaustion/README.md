# Welcome

Purpose of this demo is to explore different approaches to k8s IP Address Management (IPAM) by examining Pod IP exhaustion mitigation strategies in GKE and EKS.

Managed Kubernetes distributions rely on the computing and networking primitives of the specific cloud platforms they are built on, often exhibiting substantial variations beyond the fundamental principles. Additionally Kubernetes itself provides hundreds of configuration options which further contributes to discrepancies.

## Source Code

The clusters for this demore were provisioned using source code in this repo:

GKE: [gcp/terraform](https://github.com/olga-mir/k8s/tree/v0.0.2/gcp/terraform)

EKS: [aws/eksctl](https://github.com/olga-mir/k8s/tree/v0.0.2/aws/eksctl)

## Intro

Kubernetes networking model requires that every pod has its own IP and any pod can communicate with any other pod in the cluster. Kubernetes itself doesn't implement this model, nor does it prescribe how to implement it. In early days CNIs implemented an overlay network model (tunnel). Packets traveling between pods on different nodes were encapsulated, incurring bandwidth and processing overhead. In this model pod IPs are opaque to the network and therefore they have no constraints.

With the rise of managed k8s, cloud providers implemented solutions that integrate directly with underlying VPC and pod IPs become directly routable on the VPC, making them first-class citizen. This is often referred to as native VPC, integrated, flat network or even underlay. Because Pod IPs are now visible on the network they become expensive commodity since they must avoid collisions with all other services running in the VPC and connected networks.

When pod IPs are allocated to the nodes is controlled by `--allocate-node-cidrs` flag in `kube-controller-manager`. If it is set then each node is allocated a slice of the Pod IP range at the time when node is created. GKE implements this approach. EKS on the other hand, allocates IPs in a more granular way and not necessarily on the time of node creation.

# GKE

<details>
  <summary>Pod IP Exhaustion in GKE</summary>

# Network

GCP subnet consists of Primary IP range and optionally Secondary IP ranges. In GKE, node's IPs are allocated from Primary range, Pods and Services IPs are allocated from secondary ranges. Each nodepool is allocated a secondary pod range, from which Pod IP ranges are allocated to the nodes in this nodepool.

One secondary range can be allocated to more than one nodepool and each nodepool can have only one secondary range associated with it.

In the basic scenario there is one secondary range on the subnet which is used by the cluster as default pod IP range:

<img src="./images/ip-demo-gke-basic-subnet.png" width="250">


</details>


# EKS

<details>
  <summary>Pod IP Exhaustion in EKS</summary>

  TODO

  https://github.com/olga-mir/k8s/pull/5

</details>

# References

[Kubernetes networking model](https://kubernetes.io/docs/concepts/services-networking/)
