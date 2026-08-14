resource "google_secret_manager_secret" "db_password" {

  project = var.project_id

  secret_id = var.db_secret_id

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_password" {

  secret = google_secret_manager_secret.db_password.id

  secret_data = var.db_password

}


resource "google_secret_manager_secret" "smtp_password" {

  project = var.project_id

  secret_id = var.smtp_secret_id

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "smtp_password" {

  secret = google_secret_manager_secret.smtp_password.id

  secret_data = var.smtp_password

}