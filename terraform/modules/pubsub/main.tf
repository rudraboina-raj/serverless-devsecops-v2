resource "google_pubsub_topic" "topic" {
  project = var.project_id
  name    = var.topic_name
}

# =====================================================
# Employee Events Subscription
# =====================================================

resource "google_pubsub_subscription" "subscription" {
  project = var.project_id
  name    = var.subscription_name
  topic   = google_pubsub_topic.topic.id

  ack_deadline_seconds       = 10
  message_retention_duration = "604800s"
}

# =====================================================
# Employee Notification Push Subscription
# =====================================================

resource "google_pubsub_subscription" "notification_push_subscription" {
  project = var.project_id
  name    = "notification-push-sub"
  topic   = google_pubsub_topic.topic.id

  ack_deadline_seconds       = 10
  message_retention_duration = "604800s"

  push_config {
    push_endpoint = var.notification_push_endpoint
  }
}

# =====================================================
# Payment Events Topic
# =====================================================

resource "google_pubsub_topic" "payment_topic" {
  project = var.project_id
  name    = var.payment_topic_name
}

# =====================================================
# Payment Events Subscription
# =====================================================

resource "google_pubsub_subscription" "payment_subscription" {
  project = var.project_id
  name    = var.payment_subscription_name
  topic   = google_pubsub_topic.payment_topic.id

  ack_deadline_seconds       = 10
  message_retention_duration = "604800s"
}

# =====================================================
# Payment Notification Push Subscription
# =====================================================

resource "google_pubsub_subscription" "payment_push_subscription" {
  project = var.project_id
  name    = "payment-push-sub"
  topic   = google_pubsub_topic.payment_topic.id

  ack_deadline_seconds       = 10
  message_retention_duration = "604800s"

  push_config {
    push_endpoint = var.payment_push_endpoint
  }
}
