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
