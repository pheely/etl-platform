resource "google_pubsub_topic" "etl_job_status_pubsub_topic" {
    name    = var.etl_job_status_pubsub_topic_name
    project = var.project_id
}
