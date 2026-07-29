# Create the Artifact Registry repository for Cloud Run images
resource "google_artifact_registry_repository" "cloud_run_repo" {
  project       = "py-service-01"
  location      = "northamerica-northeast1"
  
  # The identifier used in your deployment URLs
  repository_id = var.artifact_registry_id
  description   = "Docker repository for Cloud Run source code deployments"
  
  # Must be set to DOCKER for container images
  format        = "DOCKER"

  kms_key_name = google_kms_crypto_key.gar_key.id
  depends_on = [ google_kms_crypto_key_iam_member.artifact_registry_service_agent_kms_access ]
}

resource "google_artifact_registry_repository_iam_member" "cloud_run_service_agent_pull" {
  project    = "py-service-01"
  location   = "northamerica-northeast1"
  repository = google_artifact_registry_repository.cloud_run_repo.name
  role       = "roles/artifactregistry.reader"
  
  # Target the system-level Cloud Run orchestration engine agent
  member     = "serviceAccount:service-${data.google_project.current.number}@serverless-robot-prod.iam.gserviceaccount.com"
}