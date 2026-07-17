locals {
  network_name = "py-workload-vpc"

  composer_envs = {
    nane1 = {
      env_name                = "composer-nane1"
      region                  = "northamerica-northeast1"
      subnetwork_name         = "composer-nane1"
      network_attachment_name = "composer-na-nane1"
      primary_range           = "10.0.1.0/28"
    }

    # nane2 = {
    #   env_name                = "composer-nane2"
    #   region                  = "northamerica-northeast2"
    #   subnetwork_name         = "composer-nane2"
    #   network_attachment_name = "composer-na-nane2"
    #   primary_range           = "10.0.1.16/28"
    # }
  }

  network_self_link = "projects/${var.host_project_id}/global/networks/${local.network_name}"

  labels = {
    app         = "composer"
    environment = var.environment
    managed_by  = "terraform"
  }
}


data "google_compute_subnetwork" "composer_subnets" {
    for_each = local.composer_envs
    name    = each.value.subnetwork_name
    region  = each.value.region
    project = var.host_project_id
}