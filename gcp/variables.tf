variable "project_id" {
  description = "Project ID"
  type        = string
}

variable "region" {
  description = "Region where to provision cluster"
  type        = string
}

variable "channel" {
  description = "Release channel"
  type        = string
}

variable "cluster_name" {
  type    = string
  default = "dev" // TODO - how did it get broken?
}

variable "network" {
  type = string
}

variable "subnetwork" {
  type = string
}
