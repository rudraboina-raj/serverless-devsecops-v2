# =====================================================
# Artifact Registry
# =====================================================

module "artifact_registry" {

  source = "./modules/artifact-registry"

  project_id    = var.project_id
  region        = var.region
  repository_id = var.repository_id

}

# =====================================================
# Network
# =====================================================

module "network" {

  source = "./modules/network"

  project_id = var.project_id
  region     = var.region

  network_name = var.network_name
  subnet_name  = var.subnet_name
  subnet_cidr  = var.subnet_cidr

}

# =====================================================
# Project Services
# =====================================================

module "project_services" {

  source = "./modules/project-services"

  project_id = var.project_id

}

# =====================================================
# Private Service Access
# =====================================================

module "private_service_access" {

  source = "./modules/private-service-access"

  project_id = var.project_id

  network_self_link = module.network.self_link

  depends_on = [
    module.project_services
  ]

}

# =====================================================
# Serverless VPC Connector
# =====================================================

module "serverless_vpc_connector" {

  source = "./modules/serverless-vpc-connector"

  project_id = var.project_id
  region     = var.region

  network_name = module.network.network_name

  depends_on = [
    module.private_service_access
  ]

}

# =====================================================
# Secret Manager
# =====================================================
module "secret_manager" {

  source = "./modules/secret-manager"

  project_id = var.project_id

  db_secret_id = "db-password"
  db_password  = var.db_password

  smtp_secret_id = "smtp-password"
  smtp_password  = var.smtp_password

}
# =====================================================
# Employee Service Account
# =====================================================

module "employee_service_account" {

  source = "./modules/service-account"

  project_id = var.project_id

  account_id   = var.employee_service_account_id
  display_name = var.employee_service_account_name

}

# =====================================================
# Cloud SQL
# =====================================================

module "cloud_sql" {

  source = "./modules/cloud-sql"

  project_id = var.project_id
  region     = var.region

  instance_name = var.instance_name

  network_self_link = module.network.self_link

  database_name = var.database_name

  db_username = var.db_username
  db_password = var.db_password

  depends_on = [
    module.private_service_access,
    module.serverless_vpc_connector,
    module.secret_manager
  ]

}

# =====================================================
# Employee Service - Cloud Run
# =====================================================

module "employee_cloud_run" {

  source = "./modules/cloud-run"

  project_id = var.project_id
  region     = var.region

  service_name = var.employee_service_name
  image        = var.employee_service_image

  # NEW
  service_account = module.employee_service_account.email

  container_port = 8080

  vpc_connector = module.serverless_vpc_connector.connector_id

  # -------------------------------------------------------
  # Normal Environment Variables
  # -------------------------------------------------------

  environment_variables = {

    DEBUG = "false"

    DB_HOST = module.cloud_sql.private_ip_address

    DB_PORT = "5432"

    DB_NAME = var.database_name

    DB_USERNAME = var.db_username

    PROJECT_ID = var.project_id

    EMPLOYEE_EVENTS_TOPIC = var.employee_events_topic_name

  }

  # -------------------------------------------------------
  # Secret Manager Environment Variables
  # -------------------------------------------------------

  secret_environment_variables = {

    DB_PASSWORD = {

      secret  = module.secret_manager.db_secret_name
      version = "latest"

    }

  }

  depends_on = [
    module.cloud_sql,
    module.serverless_vpc_connector,
    module.secret_manager,
    module.employee_service_account
  ]

}

# =====================================================
# Product Service - Cloud Run
# =====================================================

module "product_cloud_run" {

  source = "./modules/cloud-run"

  project_id = var.project_id
  region     = var.region

  service_name = var.product_service_name
  image        = var.product_service_image

  container_port = 8080

  service_account = module.employee_service_account.email

  vpc_connector = module.serverless_vpc_connector.connector_id

  # -------------------------------------------------------
  # Normal Environment Variables
  # -------------------------------------------------------

  environment_variables = {

    DEBUG = "false"

    DB_HOST = module.cloud_sql.private_ip_address

    DB_PORT = "5432"

    DB_NAME = var.database_name

    DB_USERNAME = var.db_username

  }

  # -------------------------------------------------------
  # Secret Manager Environment Variables
  # -------------------------------------------------------

  secret_environment_variables = {

    DB_PASSWORD = {

      secret = module.secret_manager.db_secret_name

      version = "latest"

    }

  }

  depends_on = [
    module.cloud_sql,
    module.serverless_vpc_connector,
    module.secret_manager,
    module.employee_service_account
  ]

}

# =====================================================
# Notification Service - Cloud Run
# =====================================================

module "notification_cloud_run" {

  source = "./modules/cloud-run"

  project_id = var.project_id
  region     = var.region

  service_name = var.notification_service_name

  image = var.notification_service_image

  service_account = module.employee_service_account.email

  container_port = 8080

  vpc_connector = module.serverless_vpc_connector.connector_id

  # -------------------------------------------------------
  # Normal Environment Variables
  # -------------------------------------------------------

  environment_variables = {

    DEBUG = "false"

    PROJECT_ID = var.project_id

    PAYMENT_EVENTS_SUBSCRIPTION = var.payment_events_subscription_name

    SMTP_SERVER = var.smtp_server

    SMTP_PORT = var.smtp_port

    SMTP_EMAIL = var.smtp_email


  }

  # -------------------------------------------------------
  # Secret Manager Environment Variables
  # -------------------------------------------------------

  secret_environment_variables = {

    SMTP_PASSWORD = {

      secret  = module.secret_manager.smtp_secret_name
      version = "latest"

    }

  }

  depends_on = [
    module.project_services,
    module.employee_service_account,
    module.serverless_vpc_connector,
    module.pubsub
  ]

}

# =====================================================
# Order Service - Cloud Run
# =====================================================

module "order_cloud_run" {

  source = "./modules/cloud-run"

  project_id = var.project_id
  region     = var.region

  service_name = var.order_service_name
  image        = var.order_service_image

  container_port = 8080

  service_account = module.employee_service_account.email

  vpc_connector = module.serverless_vpc_connector.connector_id

  # -------------------------------------------------------
  # Normal Environment Variables
  # -------------------------------------------------------

  environment_variables = {

    DEBUG = "false"

    DB_HOST = module.cloud_sql.private_ip_address

    DB_PORT = "5432"

    DB_NAME = var.database_name

    DB_USERNAME = var.db_username

    PROJECT_ID = var.project_id

  }

  # -------------------------------------------------------
  # Secret Manager Environment Variables
  # -------------------------------------------------------

  secret_environment_variables = {

    DB_PASSWORD = {

      secret  = module.secret_manager.db_secret_name
      version = "latest"

    }

  }

  depends_on = [
    module.cloud_sql,
    module.serverless_vpc_connector,
    module.secret_manager,
    module.employee_service_account
  ]

}

# =====================================================
# Payment Service - Cloud Run
# =====================================================

module "payment_cloud_run" {

  source = "./modules/cloud-run"

  project_id = var.project_id
  region     = var.region

  service_name = var.payment_service_name

  image = var.payment_service_image

  container_port = 8080

  service_account = module.employee_service_account.email

  vpc_connector = module.serverless_vpc_connector.connector_id

  # -------------------------------------------------------
  # Normal Environment Variables
  # -------------------------------------------------------

  environment_variables = {

    DEBUG = "false"

    DB_HOST = module.cloud_sql.private_ip_address

    DB_PORT = "5432"

    DB_NAME = var.database_name

    DB_USERNAME = var.db_username

    PROJECT_ID = var.project_id

    PAYMENT_EVENTS_TOPIC = var.payment_events_topic_name

  }

  # -------------------------------------------------------
  # Secret Manager Environment Variables
  # -------------------------------------------------------

  secret_environment_variables = {

    DB_PASSWORD = {

      secret = module.secret_manager.db_secret_name

      version = "latest"

    }

  }

  depends_on = [
    module.cloud_sql,
    module.serverless_vpc_connector,
    module.secret_manager,
    module.employee_service_account,
    module.pubsub
  ]

}
# =====================================================
# Pub/Sub
# =====================================================

module "pubsub" {

  source = "./modules/pubsub"

  project_id = var.project_id

  topic_name = var.employee_events_topic_name

  subscription_name = var.employee_events_subscription_name

  payment_topic_name = var.payment_events_topic_name

  payment_subscription_name = var.payment_events_subscription_name

  notification_push_endpoint = "https://notification-service-460587643228.asia-south1.run.app/pubsub"

  payment_push_endpoint = "https://notification-service-3hf4oltfcq-el.a.run.app/pubsub"

  depends_on = [
    module.project_services
  ]

}
