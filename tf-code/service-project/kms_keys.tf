resource "google_kms_key_ring" "composer_key_ring" {
  name     = var.composer_kms_key_ring_name
  location = var.region
  project  = var.project_id
}

resource "google_kms_crypto_key" "composer_key" {
  name            = var.composer_kms_key_name
  key_ring        = google_kms_key_ring.composer_key_ring.id
  rotation_period = "2592000s"
  purpose         = "ENCRYPT_DECRYPT"

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_kms_key_ring" "dataproc_key_ring" {
  name = var.dataproc_key_ring_name
  # the key region must match dataproc's region
  location = var.region
  project  = var.project_id
}

resource "google_kms_crypto_key" "dataproc_key" {
  name            = var.dataproc_key_name
  key_ring        = google_kms_key_ring.dataproc_key_ring.id
  rotation_period = "2592000s"
  purpose         = "ENCRYPT_DECRYPT"

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_kms_key_ring" "artifact_registry_keyring" {
  name     = var.artifact_registry_keyring_name
  location = var.region
  project  = var.project_id
}

resource "google_kms_crypto_key" "gar_key" {
  name            = var.artifact_registry_key_name
  key_ring        = google_kms_key_ring.artifact_registry_keyring.id
  rotation_period = "157680000s"
  purpose         = "ENCRYPT_DECRYPT"

  lifecycle {
    prevent_destroy = false
  }
}

# composer service agent
resource "google_kms_crypto_key_iam_member" "composer_service_agent_composer_kms_access" {
  crypto_key_id = google_kms_crypto_key.composer_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.current.number}@cloudcomposer-accounts.iam.gserviceaccount.com"
}