
resource "google_compute_network" "main_vpc" {
  auto_create_subnetworks = false
  mtu                     = 1460
  name                    = var.network
  project                 = var.project_id
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "cluster_subnetwork" {
  ip_cidr_range              = "10.0.0.0/8"
  name                       = "cluster-subnetwork"
  network                    = var.network
  private_ip_google_access   = true
  private_ipv6_google_access = "DISABLE_GOOGLE_ACCESS"
  project                    = var.project_id
  purpose                    = "PRIVATE"
  region                     = var.region

  secondary_ip_range {
    ip_cidr_range = "10.1.0.0/16"
    range_name    = "pod-range"
  }

  secondary_ip_range {
    ip_cidr_range = "10.2.0.0/16"
    range_name    = "svc-range"
  }

  stack_type = "IPV4_ONLY"
}
