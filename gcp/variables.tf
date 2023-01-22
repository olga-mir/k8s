variable "project_id" {
  description = "Project ID"
  type        = string
}

variable "region" {
  description = "Region where to provision cluster"
  type        = string
}

variable "k8s_version" {
  description = "Kubernetes version"
  type        = string
}

variable "cluster_name" {
  type = string
}

variable "network" {
  type = string
}
