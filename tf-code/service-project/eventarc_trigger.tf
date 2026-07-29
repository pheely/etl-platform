resource "google_eventarc_trigger" "gcs_to_cloud_run" {
  name            = "gcs-file-finalize-trigger"
  location        = var.region
  service_account = google_service_account.eventarc_trigger_sa.email

  # 1. Specify the Cloud Storage object creation event type
  matching_criteria {
    attribute = "type"
    value     = "google.cloud.storage.object.v1.finalized"
  }

  # 2. Scope the trigger to the specific storage bucket
  matching_criteria {
    attribute = "bucket"
    value     = google_storage_bucket.etl_input_bucket.name
  }

  # Target destination: Cloud Run Service
  destination {
    cloud_run_service {
      service = google_cloud_run_v2_service.composer_trigger_service.name
      region  = var.region
      path    = "/post" # Route to root handler inside the app
    }
  }

  depends_on = [
    google_project_iam_member.gcs_pubsub_publishing,
    google_project_iam_member.eventarc_event_receiver,
    google_service_account.eventarc_trigger_sa
  ]
}