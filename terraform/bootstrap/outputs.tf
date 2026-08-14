output "state_bucket" {
  description = "Terraform remote state bucket"

  value = google_storage_bucket.terraform_state.name
}