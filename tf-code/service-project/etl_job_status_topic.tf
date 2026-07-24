resource "google_pubsub_topic" "etl_job_status_pubsub_topic" {
  name    = var.etl_job_status_pubsub_topic_name
  project = var.project_id
}

resource "google_pubsub_subscription" "etl_job_status_subscription" {
  name                       = var.etl_job_status_subscription_name
  project                    = var.project_id
  topic                      = google_pubsub_topic.etl_job_status_pubsub_topic.id
  ack_deadline_seconds       = 360
  message_retention_duration = "86400s"
  retain_acked_messages      = false
}
