resource "google_service_account" "composer_sa" {
    account_id   = var.composer_service_account_id
    display_name = "Cloud Composer Environment Service Account"
    project      = var.project_id
}

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