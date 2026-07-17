locals {
    network_name = "py-workload-vpc"
    composer_nane1_primary_range = "10.0.1.0/28"
    # composer_nane1_pods_range = "10.1.0.0/20"
    # composer_nane1_services_range = "10.2.0.0/24"

    composer_nane2_primary_range = "10.0.1.16/28"
    # composer_nane2_pods_range = "10.1.16.0/20"
    # composer_nane2_services_range = "10.2.16.0/24"

    composer_internal_ranges = [
        local.composer_nane1_primary_range,
        # local.composer_nane1_pods_range,
        # local.composer_nane1_services_range,

        local.composer_nane2_primary_range,
        # local.composer_nane2_pods_range,
        # local.composer_nane2_services_range
    ]

    private_google_access_ranges = "199.36.153.8/30"

    # Internal RFC1918 destinations.
    # You can tighten this later to only approved internal ranges
    private_rfc1918_ranges = [
        "10.0.0.0/8",
        "172.16.0.0/12",
        "192.168.0.0/16",
    ]
}

# Rule 1 - Allow internal ingress between Composer ranges
# No longer required for Composer v3 
# resource "google_compute_firewall" "allow_composer_internal_ingress" {
#     name    = "allow-composer-internal-ingress"
#     project = var.project_id
#     network = local.network_name
#     priority = 1000
#     description = "Allow internal ingress between Composer nodes, pod, and service ranges in nane1 and nane2."

#     source_ranges = local.composer_internal_ranges

#     allow {
#         protocol = "tcp"
#     }
#     allow {
#         protocol = "udp"
#     }
#     allow {
#         protocol = "icmp"
#     }

#     log_config {
#         metadata = "INCLUDE_ALL_METADATA"
#     }
#     target_tags   = ["composer"]
# }

# Rule 2 - Allow egress to Private Google Access
resource "google_compute_firewall" "allow_composer_private_google_access_egress" {
    name    = "allow-composer-private-google-access-egress"
    project = var.project_id
    network = local.network_name
    direction = "EGRESS"
    priority = 1000
    description = "Allow Composer egress to private.googleapis.com through Private Google Access."

    destination_ranges = [local.private_google_access_ranges]

    allow {
        protocol = "tcp"
        ports    = ["443"]
    }

    log_config {
        metadata = "INCLUDE_ALL_METADATA"
    }
    target_tags   = ["pga"]
}

# Rule 3 - Allow egress to internal private destinations
# This is too broad. Remove it for now. If you need to allow egress to internal 
# destinations, you can add specific rules for those destinations.
# resource "google_compute_firewall" "allow_composer_private_egress" {
#     name    = "allow-composer-private-egress"
#     project = var.project_id
#     network = local.network_name
#     direction = "EGRESS"
#     priority = 1000
#     description = "Allow Composer egress to internal RFC1918 private ranges."

#     destination_ranges = local.private_rfc1918_ranges

#     allow {
#         protocol = "tcp"
#     }
#     allow {
#         protocol = "udp"
#     }
#     allow {
#         protocol = "icmp"
#     }

#     log_config {
#         metadata = "INCLUDE_ALL_METADATA"
#     }
# }

# Rule 4 - Deny all remaining internet egress
resource "google_compute_firewall" "deny_composer_internet_egress" {
    name    = "deny-composer-internet-egress"
    project = var.project_id
    network = local.network_name
    direction = "EGRESS"
    priority = 65534
    description = "Deny all remaining Composer egress to enforce private-only Composer networking."

    destination_ranges = ["0.0.0.0/0"]

    deny {
        protocol = "all"
    }

    log_config {
        metadata = "INCLUDE_ALL_METADATA"
    }
}

resource "google_compute_firewall" "allow_dataproc_ingress_traffic" {
    name = "allow-dataproc-subnet-ingress"
    project = var.project_id
    network = local.network_name
    direction = "INGRESS"
    priority = 1000
    description = "Allow ingress inside dataproc subnet"

    source_ranges = ["10.0.2.0/26"]

    allow {
        protocol = "tcp"
    }
}

resource "google_compute_firewall" "allow_dataproc_egress_traffic" {
    name = "allow-dataproc-subnet-egress"
    project = var.project_id
    network = local.network_name
    direction = "EGRESS"
    priority = 1000
    description = "Allow egress inside dataproc subnet"

    destination_ranges = ["10.0.2.0/26"]
    allow {
        protocol = "tcp"
    }
}
