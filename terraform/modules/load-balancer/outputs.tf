output "load_balancer_ip" {
  description = "Global IP address of the Load Balancer"
  value       = google_compute_global_address.load_balancer.address
}

output "security_policy_name" {
  description = "Cloud Armor security policy name"
  value       = google_compute_security_policy.cloud_armor.name
}

output "url_map_name" {
  description = "Load Balancer URL map name"
  value       = google_compute_url_map.main.name
}

output "employee_backend_name" {
  description = "Employee backend service name"
  value       = google_compute_backend_service.employee.name
}

output "product_backend_name" {
  description = "Product backend service name"
  value       = google_compute_backend_service.product.name
}

output "order_backend_name" {
  description = "Order backend service name"
  value       = google_compute_backend_service.order.name
}

output "payment_backend_name" {
  description = "Payment backend service name"
  value       = google_compute_backend_service.payment.name
}

output "notification_backend_name" {
  description = "Notification backend service name"
  value       = google_compute_backend_service.notification.name
}
