# Welcome

Purpose of this demo is to explore different approaches to k8s IP Address Management (IPAM) by examining Pod IP exhaustion mitigation strategies in GKE and EKS.

Managed Kubernetes distributions rely on the computing and networking primitives of the specific cloud platforms they are built on, often exhibiting substantial variations beyond the fundamental principles.

On top of that k8s itself comes with extensive array of configuration options, one example is `--allocate-node-cidrs` flag for `kube-controller-manger` which impacts when Pod IP(s) are allocated. GKE and EKS choose different approaches and this demo will illustrate its effects, advantages and disadvantages.

The clusters for this demore were provisioned using source code in this repo:

GKE: [gcp/terraform](https://github.com/olga-mir/k8s/tree/v0.0.2/gcp/terraform)

EKS: [aws/eksctl](https://github.com/olga-mir/k8s/tree/v0.0.2/aws/eksctl)


# A word about IPs

What's the big deal with IPs? k8s networking model requries that every pod has its own IP and that any pod can communicate with any other pod in the cluster. Kubernetes itself doesn't implement networking, nor it prescribes how to implement it. In early days CNIs implemented overlay network model, often referred as tunnel. In this approach, packets traveling between pods on different nodes were encapsulated, incurring bandwidth and processing overhead (some of these concerns have been mitigated in modern kernels, but it's a separate topic). In this model, pod IPs are opaque beyond the cluster boundaries and have constraints.

With the rise of managed k8s, cloud providers implemented solutions that integrate directly with underlying VPC and pod IPs become directly routable on the VPC, making them first-class citizen. GKE calls it "integrated" or "flat" network model. This makes IPs expensive commodity because they must avoid collisions with all other services running in the VPC and connected networks.

# GKE

<details>
  <summary>Pod IP Exhaustion in GKE</summary>

# Network

GCP subnet consists of Primary IP range and optionally Secondary IP ranges. In GKE, node's IPs are allocated from Primary range, Pods and Services IPs are allocated from secondary ranges. Each nodepool is allocated a secondary pod range, from which Pod IP ranges are allocated to the nodes in this nodepool.

One secondary range can be allocated to more than one nodepool and each nodepool can have only one secondary range associated with it.

In the basic scenario there is one secondary range on the subnet which is used by the cluster as default pod IP range:


</details>


# EKS

<details>
  <summary>Pod IP Exhaustion in EKS</summary>

  TODO

  https://github.com/olga-mir/k8s/pull/5

</details>
