output "db_secret_id" {
  description = "Full DB Secret Manager resource ID"
  value       = google_secret_manager_secret.db_password.id
}

output "db_secret_name" {
  description = "DB secret name"
  value       = google_secret_manager_secret.db_password.secret_id
}

output "smtp_secret_id" {
  description = "Full SMTP Secret Manager resource ID"
  value       = google_secret_manager_secret.smtp_password.id
}

output "smtp_secret_name" {
  description = "SMTP secret name"
  value       = google_secret_manager_secret.smtp_password.secret_id
}