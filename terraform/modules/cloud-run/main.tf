# ============================================================
# Cloud Run Service
# ============================================================

resource "google_cloud_run_v2_service" "service" {

  name     = var.service_name
  project  = var.project_id
  location = var.region

  deletion_protection = false

  ingress = "INGRESS_TRAFFIC_ALL"

  template {

    service_account = var.service_account

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    vpc_access {

      connector = var.vpc_connector
      egress    = "PRIVATE_RANGES_ONLY"
    }

    containers {

      image = var.image

      resources {

        limits = {
          cpu    = var.cpu
          memory = var.memory
        }
      }

      ports {
        container_port = var.container_port
      }

      # --------------------------------------------------------
      # Normal Environment Variables
      # --------------------------------------------------------

      dynamic "env" {

        for_each = var.environment_variables

        content {

          name  = env.key
          value = env.value
        }
      }

      # --------------------------------------------------------
      # Secret Manager Environment Variables
      # --------------------------------------------------------

      dynamic "env" {

        for_each = var.secret_environment_variables

        content {

          name = env.key

          value_source {

            secret_key_ref {

              secret  = env.value.secret
              version = env.value.version
            }
          }
        }
      }
    }
  }
}