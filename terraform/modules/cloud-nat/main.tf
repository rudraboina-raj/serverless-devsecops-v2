# ============================================================
# Cloud Router
# ============================================================

resource "google_compute_router" "router" {
  name    = "serverless-router"
  project = var.project_id
  region  = var.region
  network = var.network_self_link

  bgp {
    asn = 64514
  }
}

# ============================================================
# Cloud NAT
# ============================================================

resource "google_compute_router_nat" "nat" {
  name    = "serverless-nat"
  project = var.project_id
  region  = var.region
  router  = google_compute_router.router.name

  nat_ip_allocate_option = "AUTO_ONLY"

  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  depends_on = [
    google_compute_router.router
  ]
}