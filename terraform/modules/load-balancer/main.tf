# ============================================================
# Cloud Armor Security Policy
# ============================================================

resource "google_compute_security_policy" "cloud_armor" {
  name        = "techmart-cloud-armor"
  project     = var.project_id
  type        = "CLOUD_ARMOR"
  description = "Cloud Armor protection for TechMart Cloud Run services"

  # ----------------------------------------------------------
  # SQL Injection Protection
  # ----------------------------------------------------------

  rule {
    priority    = 1000
    action      = "deny(403)"
    description = "Block SQL injection attacks"

    match {
      expr {
        expression = "evaluatePreconfiguredWaf('sqli-v33-stable', {'sensitivity': 2})"
      }
    }
  }

  # ----------------------------------------------------------
  # XSS Protection
  # ----------------------------------------------------------

  rule {
    priority    = 1001
    action      = "deny(403)"
    description = "Block cross-site scripting attacks"

    match {
      expr {
        expression = "evaluatePreconfiguredWaf('xss-v33-stable', {'sensitivity': 2})"
      }
    }
  }

  # ----------------------------------------------------------
  # Default Allow
  # ----------------------------------------------------------

  rule {
    priority    = 2147483647
    action      = "allow"
    description = "Default allow rule"

    match {
      versioned_expr = "SRC_IPS_V1"

      config {
        src_ip_ranges = ["*"]
      }
    }
  }
}

# ============================================================
# Serverless NEG - Employee
# ============================================================

resource "google_compute_region_network_endpoint_group" "employee" {
  name                  = "employee-serverless-neg"
  project               = var.project_id
  region                = var.region
  network_endpoint_type = "SERVERLESS"

  cloud_run {
    service = var.employee_service_name
  }
}

# ============================================================
# Serverless NEG - Product
# ============================================================

resource "google_compute_region_network_endpoint_group" "product" {
  name                  = "product-serverless-neg"
  project               = var.project_id
  region                = var.region
  network_endpoint_type = "SERVERLESS"

  cloud_run {
    service = var.product_service_name
  }
}

# ============================================================
# Serverless NEG - Order
# ============================================================

resource "google_compute_region_network_endpoint_group" "order" {
  name                  = "order-serverless-neg"
  project               = var.project_id
  region                = var.region
  network_endpoint_type = "SERVERLESS"

  cloud_run {
    service = var.order_service_name
  }
}

# ============================================================
# Serverless NEG - Payment
# ============================================================

resource "google_compute_region_network_endpoint_group" "payment" {
  name                  = "payment-serverless-neg"
  project               = var.project_id
  region                = var.region
  network_endpoint_type = "SERVERLESS"

  cloud_run {
    service = var.payment_service_name
  }
}

# ============================================================
# Serverless NEG - Notification
# ============================================================

resource "google_compute_region_network_endpoint_group" "notification" {
  name                  = "notification-serverless-neg"
  project               = var.project_id
  region                = var.region
  network_endpoint_type = "SERVERLESS"

  cloud_run {
    service = var.notification_service_name
  }
}

# ============================================================
# Backend Service - Employee
# ============================================================

resource "google_compute_backend_service" "employee" {
  name                  = "employee-backend"
  project               = var.project_id
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"


  enable_cdn = true

  cdn_policy {
    cache_mode = "USE_ORIGIN_HEADERS"

    cache_key_policy {
      include_host         = true
      include_protocol     = true
      include_query_string = true
    }
  }

  security_policy = google_compute_security_policy.cloud_armor.id

  backend {
    group = google_compute_region_network_endpoint_group.employee.id
  }
}

# ============================================================
# Backend Service - Product
# ============================================================

resource "google_compute_backend_service" "product" {
  name                  = "product-backend"
  project               = var.project_id
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"


  enable_cdn = true

  cdn_policy {
    cache_mode = "USE_ORIGIN_HEADERS"

    cache_key_policy {
      include_host         = true
      include_protocol     = true
      include_query_string = true
    }
  }

  security_policy = google_compute_security_policy.cloud_armor.id

  backend {
    group = google_compute_region_network_endpoint_group.product.id
  }
}

# ============================================================
# Backend Service - Order
# ============================================================

resource "google_compute_backend_service" "order" {
  name                  = "order-backend"
  project               = var.project_id
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"


  enable_cdn = true

  cdn_policy {
    cache_mode = "USE_ORIGIN_HEADERS"

    cache_key_policy {
      include_host         = true
      include_protocol     = true
      include_query_string = true
    }
  }

  security_policy = google_compute_security_policy.cloud_armor.id

  backend {
    group = google_compute_region_network_endpoint_group.order.id
  }
}

# ============================================================
# Backend Service - Payment
# ============================================================

resource "google_compute_backend_service" "payment" {
  name                  = "payment-backend"
  project               = var.project_id
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"


  enable_cdn = true

  cdn_policy {
    cache_mode = "USE_ORIGIN_HEADERS"

    cache_key_policy {
      include_host         = true
      include_protocol     = true
      include_query_string = true
    }
  }

  security_policy = google_compute_security_policy.cloud_armor.id

  backend {
    group = google_compute_region_network_endpoint_group.payment.id
  }
}

# ============================================================
# Backend Service - Notification
# ============================================================

resource "google_compute_backend_service" "notification" {
  name                  = "notification-backend"
  project               = var.project_id
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"


  enable_cdn = true

  cdn_policy {
    cache_mode = "USE_ORIGIN_HEADERS"

    cache_key_policy {
      include_host         = true
      include_protocol     = true
      include_query_string = true
    }
  }

  security_policy = google_compute_security_policy.cloud_armor.id

  backend {
    group = google_compute_region_network_endpoint_group.notification.id
  }
}

# ============================================================
# Global Static IP
# ============================================================

resource "google_compute_global_address" "load_balancer" {
  name    = "techmart-global-ip"
  project = var.project_id
}

# ============================================================
# URL Map
# ============================================================

resource "google_compute_url_map" "main" {
  name    = "techmart-url-map"
  project = var.project_id

  default_service = google_compute_backend_service.employee.id

  # ----------------------------------------------------------
  # Path Matcher
  # ----------------------------------------------------------

  path_matcher {
    name            = "techmart-services"
    default_service = google_compute_backend_service.employee.id

    # Employee
    path_rule {
      paths   = ["/employee/*"]
      service = google_compute_backend_service.employee.id

      route_action {
        url_rewrite {
          path_prefix_rewrite = "/"
        }
      }
    }

    # Product
    path_rule {
      paths   = ["/product/*"]
      service = google_compute_backend_service.product.id

      route_action {
        url_rewrite {
          path_prefix_rewrite = "/"
        }
      }
    }

    # Order
    path_rule {
      paths   = ["/order/*"]
      service = google_compute_backend_service.order.id

      route_action {
        url_rewrite {
          path_prefix_rewrite = "/"
        }
      }
    }

    # Payment
    path_rule {
      paths   = ["/payment/*"]
      service = google_compute_backend_service.payment.id

      route_action {
        url_rewrite {
          path_prefix_rewrite = "/"
        }
      }
    }

    # Notification
    path_rule {
      paths   = ["/notification/*"]
      service = google_compute_backend_service.notification.id

      route_action {
        url_rewrite {
          path_prefix_rewrite = "/"
        }
      }
    }
  }

  host_rule {
    hosts        = ["*"]
    path_matcher = "techmart-services"
  }
}

# ============================================================
# HTTP Target Proxy
# ============================================================

resource "google_compute_target_http_proxy" "http" {
  name    = "techmart-http-proxy"
  project = var.project_id
  url_map = google_compute_url_map.main.id
}

# ============================================================
# Global HTTP Forwarding Rule
# ============================================================

resource "google_compute_global_forwarding_rule" "http" {
  name                  = "techmart-http-forwarding-rule"
  project               = var.project_id
  target                = google_compute_target_http_proxy.http.id
  port_range            = "80"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  network_tier          = "PREMIUM"
  ip_address            = google_compute_global_address.load_balancer.address
}
