variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "employee_service_name" {
  description = "Employee Cloud Run service"
  type        = string
}

variable "product_service_name" {
  description = "Product Cloud Run service"
  type        = string
}

variable "order_service_name" {
  description = "Order Cloud Run service"
  type        = string
}

variable "payment_service_name" {
  description = "Payment Cloud Run service"
  type        = string
}

variable "notification_service_name" {
  description = "Notification Cloud Run service"
  type        = string
}