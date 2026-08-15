output "cloud_sql_instance_name" {
  description = "Cloud SQL instance name"
  value       = module.cloud_sql.instance_name
}

output "cloud_sql_private_ip" {
  description = "Cloud SQL private IP address"
  value       = module.cloud_sql.private_ip_address
}

output "cloud_sql_connection_name" {
  description = "Cloud SQL connection name"
  value       = module.cloud_sql.connection_name
}

output "database_name" {
  description = "Application database name"
  value       = module.cloud_sql.database_name
}

# ============================================================
# Load Balancer / Cloud Armor / CDN
# ============================================================

output "load_balancer_ip" {
  description = "Global external IP address of the Load Balancer"
  value       = module.load_balancer.load_balancer_ip
}

output "cloud_armor_policy_name" {
  description = "Cloud Armor security policy"
  value       = module.load_balancer.security_policy_name
}

output "load_balancer_url_map" {
  description = "Load Balancer URL map"
  value       = module.load_balancer.url_map_name
}

output "employee_backend_name" {
  description = "Employee backend service"
  value       = module.load_balancer.employee_backend_name
}

output "product_backend_name" {
  description = "Product backend service"
  value       = module.load_balancer.product_backend_name
}

output "order_backend_name" {
  description = "Order backend service"
  value       = module.load_balancer.order_backend_name
}

output "payment_backend_name" {
  description = "Payment backend service"
  value       = module.load_balancer.payment_backend_name
}

output "notification_backend_name" {
  description = "Notification backend service"
  value       = module.load_balancer.notification_backend_name
}