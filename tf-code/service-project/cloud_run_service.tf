resource "google_cloud_run_v2_service" "composer_trigger_service" {
  project  = var.project_id
  name     = "composer-trigger-service"
  location = var.region
#   ingress  = "INGRESS_TRAFFIC_INTERNAL_ONLY" # Restrict to internal/perimeter invocations
  ingress = "INGRESS_TRAFFIC_ALL"

  deletion_protection = false
  template {
    # Assign the minimal execution identity
    service_account = google_service_account.cloudrun_sa.email

    # vpc_access {
    #   #   egress = "ALL_TRAFFIC"
    #   egress = "PRIVATE_RANGES_ONLY"

    #   network_interfaces {
    #     network    = "projects/py-host-01/global/networks/py-workload-vpc"
    #     subnetwork = "projects/py-host-01/regions/northamerica-northeast1/subnetworks/cloudrun-egress-subnet-nane1"

    #     # Explicitly tag the Cloud Run instances
    #     tags = ["pga"]
    #   }
    # }

    containers {
      image = "northamerica-northeast1-docker.pkg.dev/py-service-01/etl/composer-trigger:v2"

      # Pass your workflow parameters directly into the container environment
      #   env {
      #     name  = "COMPOSER_WEB_SERVER_URL"
      #     value = "https://5eaa404140e04fc1ac120a476b7efb14-dot-northamerica-northeast1.composer.googleusercontent.com"
      #   }

      env {
        name  = "COMPOSER_WEB_SERVER_URL"
        value = "https://f3cc5bb0e516408fbe0852fcdde2bb10-dot-northamerica-northeast1.composer.googleusercontent.com"
      }

      env {
        name  = "DAG_ID"
        value = "dataproc_serverless_production_pipeline"
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }
    }
  }
}

resource "google_cloud_run_v2_service_iam_member" "allow_invoker" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.composer_trigger_service.name
  role     = "roles/run.invoker"
  member   = "user:admin@pycloudlabs.cc"
}
