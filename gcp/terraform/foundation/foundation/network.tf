
resource "google_compute_network" "main_vpc" {
  auto_create_subnetworks = false
  mtu                     = 1460
  name                    = var.network
  project                 = var.project_id
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "cluster_subnetwork" {
  depends_on = [
    google_compute_network.main_vpc
  ]
  ip_cidr_range              = "10.0.0.0/8"
  name                       = var.subnetwork
  network                    = var.network
  private_ip_google_access   = true
  private_ipv6_google_access = "DISABLE_GOOGLE_ACCESS"
  project                    = var.project_id
  purpose                    = "PRIVATE"
  region                     = var.region

  secondary_ip_range {
    ip_cidr_range = "192.168.64.0/18"
    range_name    = "pod-range"
  }

  secondary_ip_range {
    ip_cidr_range = "192.168.128.0/18"
    range_name    = "svc-range"
  }

  stack_type = "IPV4_ONLY"
}

resource "google_compute_firewall" "allow_iap_ssh_ingress" {
  depends_on = [
    google_compute_network.main_vpc
  ]

  allow {
    ports    = ["22"]
    protocol = "tcp"
  }

  direction     = "INGRESS"
  name          = "allow-iap-ssh-ingress"
  network       = var.network
  priority      = 1000
  project       = var.project_id
  source_ranges = ["35.235.240.0/20"]
}
