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
    name     = var.dataproc_key_ring_name
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
    name = var.artifact_registry_keyring_name
    location = var.region
    project = var.project_id
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

# GCS service agent 
resource "google_kms_crypto_key_iam_member" "gcs_service_agent_composer_kms_access" {
    crypto_key_id = google_kms_crypto_key.composer_key.id
    role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
    member        = "serviceAccount:service-${data.google_project.current.number}@gs-project-accounts.iam.gserviceaccount.com"
}

# dataproc service agent
resource "google_kms_crypto_key_iam_member" "dataproc_service_agent_dataproc_kms_access" {
    crypto_key_id = google_kms_crypto_key.dataproc_key.id
    role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
    member        = "serviceAccount:service-${data.google_project.current.number}@dataproc-accounts.iam.gserviceaccount.com"
}

# GCS service agent
resource "google_kms_crypto_key_iam_member" "gcs_service_agent_dataproc_kms_access" {
    crypto_key_id = google_kms_crypto_key.dataproc_key.id
    role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
    member        = "serviceAccount:service-${data.google_project.current.number}@gs-project-accounts.iam.gserviceaccount.com"
}

# compute engine service agent to 
resource "google_kms_crypto_key_iam_member" "compute_service_agent_dataproc_kms_access" {
    crypto_key_id = google_kms_crypto_key.dataproc_key.id
    role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
    member        = "serviceAccount:service-${data.google_project.current.number}@compute-system.iam.gserviceaccount.com"
}

# artifact registry service agent
resource "google_kms_crypto_key_iam_member" "artifact_registry_service_agent_kms_access" {
    crypto_key_id = google_kms_crypto_key.gar_key.id
    role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
    member        = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-artifactregistry.iam.gserviceaccount.com"
}

# cloud run service agent
resource "google_kms_crypto_key_iam_member" "cloudrun_service_agent_kms_access" {
    crypto_key_id = google_kms_crypto_key.gar_key.id
    role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
    member        = "serviceAccount:service-${data.google_project.current.number}@serverless-robot-prod.iam.gserviceaccount.com"
}
