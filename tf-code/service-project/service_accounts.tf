data "google_storage_project_service_account" "gcs_account" {
  project = var.project_id
}

resource "google_service_account" "dataproc_sa" {
  account_id   = var.dataproc_service_account_id
  display_name = "Dataproc Serverless Batch Service Account"
  project      = var.project_id
}

resource "google_service_account" "composer_sa" {
  account_id   = var.composer_service_account_id
  display_name = "Cloud Composer Environment Service Account"
  project      = var.project_id
}

resource "google_service_account" "cloudrun_sa" {
  account_id   = var.cloudrun_service_account_id
  display_name = "Cloud Run Service Account"
  project      = var.project_id
}

# Dataproc SA Permissions
resource "google_project_iam_member" "dataproc_sa_dataproc_worker" {
  project = var.project_id
  role    = "roles/dataproc.worker"
  member  = "serviceAccount:${google_service_account.dataproc_sa.email}"
}

# Composer SA permissions
resource "google_project_iam_member" "composer_worker" {
  project = var.project_id
  role    = "roles/composer.worker"
  member  = "serviceAccount:${google_service_account.composer_sa.email}"
}

# Required if DAGs will launch Dataproc serverless batchs, read/write GCS,
# publish Pub/Sub messages, or access Secret Manager secrets.
resource "google_project_iam_member" "composer_dataproc_editor" {
  project = var.project_id
  role    = "roles/dataproc.editor"
  member  = "serviceAccount:${google_service_account.composer_sa.email}"
}

resource "google_project_iam_member" "composer_pubsub_publisher" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.composer_sa.email}"
}

resource "google_project_iam_member" "composer_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.composer_sa.email}"
}

resource "google_project_iam_member" "composer_storage_object_admin" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.composer_sa.email}"
}

resource "google_service_account_iam_member" "composer_sa_impersonate_dataproc_sa" {
  role               = "roles/iam.serviceAccountUser"
  service_account_id = google_service_account.dataproc_sa.id
  member             = "serviceAccount:${google_service_account.composer_sa.email}"
}

# CloudRun SA permissions
resource "google_project_iam_member" "cloudrun_sa_composer_admin" {
  project = var.project_id
  # Let try a broad access first and then tighten up.
  # role    = "roles/composer.user"
  # role    = "roles/composer.view"
  # role    = "roles/composer.environmentViewer"
  role   = "roles/composer.admin"
  member = "serviceAccount:${google_service_account.cloudrun_sa.email}"
}

resource "google_project_iam_member" "cloudrun_sa_composer_user" {
  project = var.project_id
  role    = "roles/composer.user"
  member  = "serviceAccount:${google_service_account.cloudrun_sa.email}"
}

resource "google_project_iam_member" "cloudrun_sa_composer_viewer" {
  project = var.project_id
  role    = "roles/composer.viewer"
  member  = "serviceAccount:${google_service_account.cloudrun_sa.email}"
}

resource "google_project_iam_member" "cloudrun_sa_composer_iap" {
  project = var.project_id
  role    = "roles/iap.httpsResourceAccessor"
  member  = "serviceAccount:${google_service_account.cloudrun_sa.email}"
}

# Allow GCS Service Agent to publish Pub/Sub messages (required for Eventarc storage triggers)
resource "google_project_iam_member" "gcs_pubsub_publishing" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"
}

# Dedicated Service Account used by Eventarc to invoke Cloud Run
resource "google_service_account" "eventarc_trigger_sa" {
  account_id   = "eventarc-gcs-trigger-sa"
  display_name = "Eventarc Storage Trigger Runner"
}

# Grant Eventarc SA the ability to receive events
resource "google_project_iam_member" "eventarc_event_receiver" {
  project = var.project_id
  role    = "roles/eventarc.eventReceiver"
  member  = "serviceAccount:${google_service_account.eventarc_trigger_sa.email}"
}

# Grant Eventarc SA the ability to invoke Cloud Run
resource "google_project_iam_member" "eventarc_run_invoker" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.eventarc_trigger_sa.email}"
}

