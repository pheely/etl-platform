resource "google_kms_key_ring" "composer_key_ring" {
    name     = var.kms_key_ring_name
    location = var.region
    project  = var.project_id
}

resource "google_kms_crypto_key" "composer_key" {
    name            = var.kms_key_name
    key_ring        = google_kms_key_ring.composer_key_ring.id
    rotation_period = "2592000s"
    purpose         = "ENCRYPT_DECRYPT"

    lifecycle {
        prevent_destroy = false
    }
}


data "google_project" "current" {
    project_id = var.project_id
}

resource "google_kms_crypto_key_iam_member" "composer_service_agent_kms_access" {
    crypto_key_id = google_kms_crypto_key.composer_key.id
    role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
    member        = "serviceAccount:service-${data.google_project.current.number}@cloudcomposer-accounts.iam.gserviceaccount.com"
}

# The same key will also be used by the GCS service agent to 
# encrypt/decrypt the state file in the GCS bucket. 
resource "google_kms_crypto_key_iam_member" "gcs_service_agent_kms_access" {
    crypto_key_id = google_kms_crypto_key.composer_key.id
    role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
    member        = "serviceAccount:service-${data.google_project.current.number}@gs-project-accounts.iam.gserviceaccount.com"
}