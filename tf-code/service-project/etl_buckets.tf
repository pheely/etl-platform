resource "google_storage_bucket" "etl_input_bucket" {
  name                        = var.etl_input_bucket_name
  location                    = var.region
  project                     = var.project_id
  uniform_bucket_level_access = true
  force_destroy               = true

  versioning {
    enabled = true
  }

  encryption {
    default_kms_key_name = google_kms_crypto_key.dataproc_key.id
  }
}

resource "google_storage_bucket" "etl_output_bucket" {
  name                        = var.etl_output_bucket_name
  location                    = var.region
  project                     = var.project_id
  uniform_bucket_level_access = true
  force_destroy               = true

  versioning {
    enabled = true
  }

  encryption {
    default_kms_key_name = google_kms_crypto_key.dataproc_key.id
  }
}

resource "google_storage_bucket_iam_member" "eventarc_trigger_sa_bucket_viewer" {
  bucket = google_storage_bucket.etl_input_bucket.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.eventarc_trigger_sa.email}"
}

resource "google_storage_bucket_iam_member" "eventarc_trigger_sa_bucket_reader" {
  bucket = google_storage_bucket.etl_input_bucket.name
  role   = "roles/storage.legacyBucketReader"
  member = "serviceAccount:${google_service_account.eventarc_trigger_sa.email}"
}

resource "google_storage_bucket" "etl_code" {
  name                        = var.dataproc_code_bucket_name
  location                    = var.region
  project                     = var.project_id
  uniform_bucket_level_access = true
  force_destroy               = true

  versioning {
    enabled = true
  }

  encryption {
    default_kms_key_name = google_kms_crypto_key.dataproc_key.id
  }
}
