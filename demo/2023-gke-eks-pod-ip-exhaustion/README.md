# Welcome

Purpose of this demo is to explore different approaches to k8s IP Addreess Management (IPAM) by identifying and addressing issues related to Pod IP exhaustion.

Managed Kubernetes distributions rely on the computing and networking structures of the specific cloud platforms they are built on, often exhibiting substantial variations beyond the fundamental principles.

On top of that k8s itself comes with extensive array of configuration options, and one such example is `--allocate-node-cidrs` flag for `kube-controller-manger` which impacts when Pod IP(s) is allocated. GKE and EKS choose different approaches and this demo will illustrate its effects, advantages and disadvantages.

The clusters for this demore were provisioned using this repo:

GKE: https://github.com/olga-mir/k8s/tree/main/gcp/terraform

EKS: https://github.com/olga-mir/k8s/tree/main/aws/eksctl

# GKE 

<details>
  <summary>Pod IP Exhaustion in GKE</summary>

  TODO

</details>


# EKS

<details>
  <summary>Pod IP Exhaustion in EKS</summary>

  TODO

  https://github.com/olga-mir/k8s/pull/5

</details>
