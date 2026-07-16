resource "google_compute_subnetwork" "composer_subnetwork_nane1" {
    name          = "composer-nane1"
    ip_cidr_range = "10.0.0.0/20"
    region        = "northamerica-northeast1"
    project       = var.project_id
    network       = "py-workload-vpc"

    secondary_ip_range {
        range_name    = "composer-pods-nane1"
        ip_cidr_range = "10.1.0.0/20"
    }

    secondary_ip_range {
        range_name    = "composer-services-nane1"
        ip_cidr_range = "10.2.0.0/24"
    }

    private_ip_google_access = true
}

resource "google_compute_subnetwork" "composer_subnetwork_nane2" {
    name          = "composer-nane2"
    ip_cidr_range = "10.0.16.0/20"
    region        = "northamerica-northeast2"
    project       = var.project_id
    network       = "py-workload-vpc"

    secondary_ip_range {
        range_name    = "composer-pods-nane2"
        ip_cidr_range = "10.1.16.0/20"
    }

    secondary_ip_range {
        range_name    = "composer-services-nane2"
        ip_cidr_range = "10.2.16.0/24"
    }

    private_ip_google_access = true
}

# This is not required for Composer v3 that uses PSC to 
# connect to Cloud SQL.
# resource "google_compute_global_address" "psa" {
#     name          = "google-managed-services"
#     purpose       = "VPC_PEERING"
#     ip_version    = "IPV4"
#     address_type  = "INTERNAL"
#     prefix_length = 20
#     network       = "py-workload-vpc"
#     project       = var.project_id
# }