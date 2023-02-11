data "google_compute_network" "vpc" {
  name    = var.network
  project = var.project_id
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster
module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google"
  version = "24.1.0"

  depends_on = [
    data.google_compute_network.vpc
  ]

  kubernetes_version         = var.k8s_version
  project_id                 = var.project_id
  name                       = var.cluster_name
  region                     = var.region
  zones                      = ["${var.region}-b"]
  network                    = data.google_compute_network.vpc.name
  subnetwork                 = var.subnetwork
  ip_range_pods              = "pod-range"
  ip_range_services          = "svc-range"
  horizontal_pod_autoscaling = true
  default_max_pods_per_node  = 64
  datapath_provider          = "ADVANCED_DATAPATH"

  node_pools = [
    {
      name               = "default-node-pool"
      machine_type       = "e2-standard-2"
      node_locations     = "${var.region}-b"
      min_count          = 2
      max_count          = 3
      local_ssd_count    = 0
      disk_size_gb       = 50
      disk_type          = "pd-standard"
      image_type         = "COS_CONTAINERD"
      enable_gcfs        = false
      enable_gvnic       = false
      auto_repair        = true
      auto_upgrade       = true
      service_account    = "project-service-account@${var.project_id}.iam.gserviceaccount.com"
      spot               = true
      initial_node_count = 2
    },
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  node_pools_labels = {
    all = {}

    default-node-pool = {
      default-node-pool = true
    }
  }

  node_pools_metadata = {
    all = {}

    default-node-pool = {
      node-pool-metadata-custom-value = "my-node-pool"
    }
  }

  node_pools_taints = {
    all = []

    default-node-pool = [
      {
        key    = "default-node-pool"
        value  = true
        effect = "PREFER_NO_SCHEDULE"
      },
    ]
  }

  node_pools_tags = {
    all = []

    default-node-pool = [
      "default-node-pool",
    ]
  }
}

# TODO - use nodepools instead of default nodepool

# resource "google_container_node_pool" "primary_preemptible_nodes" {
#   name       = "my-node-pool"
#   location   = "us-central1"
#   cluster    = google_container_cluster.primary.name
#   node_count = 1

#   node_config {
#     preemptible  = true
#     machine_type = "e2-medium"

#     # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
#     service_account = google_service_account.default.email
#     oauth_scopes = [
#       "https://www.googleapis.com/auth/cloud-platform"
#     ]
#   }
# }
