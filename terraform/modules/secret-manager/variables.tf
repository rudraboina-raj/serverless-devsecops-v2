variable "project_id" {
  type = string
}

variable "db_secret_id" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "smtp_secret_id" {
  type = string
}

variable "smtp_password" {
  type      = string
  sensitive = true
}