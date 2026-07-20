data "google_project" "service_project" {
    project_id = var.service_project_id
}

resource "google_project_iam_member" "composer_shared_vpc_agent" {
    project = var.project_id
    # role    = "roles/composer.sharedVpcAgent"
    role    = google_project_iam_custom_role.composer_environment_creator.name
    member  = "serviceAccount:service-${data.google_project.service_project.number}@cloudcomposer-accounts.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "dataproc_network_user" {
    project = var.project_id
    role    = "roles/compute.networkUser"
    member  = "serviceAccount:service-${data.google_project.service_project.number}@dataproc-accounts.iam.gserviceaccount.com"
}

resource "google_compute_subnetwork_iam_member" "cloudrun_agent_shared_vpc_user" {
  project    = var.project_id
  region     = "northamerica-northeast1"
  subnetwork = "cloudrun-egress-subnet-nane1"
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:service-${data.google_project.service_project.number}@serverless-robot-prod.iam.gserviceaccount.com"
}