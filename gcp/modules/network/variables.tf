variable "project_id" {
  description = "Project ID"
  type        = string
}

variable "region" {
  description = "Region where to provision cluster"
  type        = string
}

variable "network" {
  type = string
}

variable "subnetwork" {
  type = string
}