locals {
    apis = [
        "cloudresourcemanager",
        "iam",
        "run",
        "artifactregistry",
        "sqladmin",
        "sql-component",
        "pubsub",
        "dataproc",
        "composer",
        "eventarc",
        "cloudkms",
        "compute",
        "serviceusage",
        "logging",
        "monitoring",
    ]
}

resource "google_project_service" "apis" {
    for_each = toset(local.apis)
    project  = var.project_id
    service  = "${each.key}.googleapis.com"
}