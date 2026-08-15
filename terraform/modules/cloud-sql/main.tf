# ============================================================
# Cloud SQL PostgreSQL Instance
# ============================================================

resource "google_sql_database_instance" "postgres" {

  name             = var.instance_name
  project          = var.project_id
  region           = var.region
  database_version = var.database_version

  # Protect the production database from accidental deletion.
  deletion_protection = true

  settings {

    tier              = var.tier
    edition           = "ENTERPRISE"
    availability_type = var.availability_type

    disk_type       = var.disk_type
    disk_size       = var.disk_size
    disk_autoresize = true

    activation_policy = "ALWAYS"
    pricing_plan      = "PER_USE"

    # --------------------------------------------------------
    # Backup
    # --------------------------------------------------------

    backup_configuration {

      enabled = true

      point_in_time_recovery_enabled = true

      start_time = "02:00"
    }

    # --------------------------------------------------------
    # Maintenance
    # --------------------------------------------------------

    maintenance_window {

      day  = 7
      hour = 3
    }

    # --------------------------------------------------------
    # Query Insights
    # --------------------------------------------------------

    insights_config {

      query_insights_enabled  = true
      record_application_tags = true
      record_client_address   = true
    }

    # --------------------------------------------------------
    # Network Configuration
    # --------------------------------------------------------

    ip_configuration {

      # Keep public IPv4 disabled for private-only database access.
      ipv4_enabled = false

      private_network = var.network_self_link
    }
  }
}

# ============================================================
# Application Database
# ============================================================

resource "google_sql_database" "application_db" {

  name     = var.database_name
  project  = var.project_id
  instance = google_sql_database_instance.postgres.name
}

# ============================================================
# Application Database User
# ============================================================

resource "google_sql_user" "application_user" {

  project  = var.project_id
  instance = google_sql_database_instance.postgres.name

  name     = var.db_username
  password = var.db_password

  # Terraform should not continuously change the DB password
  # because the password is supplied through CI/CD secrets.
  lifecycle {
    ignore_changes = [
      password
    ]
  }
}