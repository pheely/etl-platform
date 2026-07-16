# locals {
#     composer_subnetwork_parts = split("/", var.subnetwork)
# }

# data "google_compute_subnetwork" "composer_subnetwork" {
#     name    = local.composer_subnetwork_parts[5]
#     region  = local.composer_subnetwork_parts[3]
#     project = local.composer_subnetwork_parts[1]
# }

# resource "google_composer_environment" "composer_env" {
#     name   = var.composer_env_name
#     region = var.region
#     project = var.project_id

#     config {
#         enable_private_environment = true
#         enable_private_builds_only = true

#         encryption_config {
#             kms_key_name = google_kms_crypto_key.composer_key.id
#         }

#         web_server_network_access_control {
#           dynamic "allowed_ip_range" {
#             for_each = var.airflow_ui_allowed_ip_ranges
#             content {
#                 value = allowed_ip_range.value.cidr
#                 description = allowed_ip_range.value.description
#             }
#           }
#         }

#         software_config {
#             image_version = var.composer_image_version
#             # pypi_packages = var.composer_pypi_packages
#             airflow_config_overrides = {
#                 "core-dag_concurrency" = true
#             }
#             env_variables = {
#                 "ENVIRONMENT" = "dev"
#             }
#         }

#         node_config {
#             network       = data.google_compute_subnetwork.composer_subnetwork.network
#             subnetwork    = data.google_compute_subnetwork.composer_subnetwork.id
#             service_account = google_service_account.composer_sa.email
#         }

#         workloads_config {
#             scheduler {
#                 cpu = 0.5
#                 memory_gb = 2
#                 storage_gb = 1
#                 count = 1
#             }
#             web_server {
#                 cpu = 0.5
#                 memory_gb = 2
#                 storage_gb = 1
#             }
#             worker {
#                 cpu = 0.5
#                 memory_gb = 2
#                 storage_gb = 1
#                 min_count = 0
#                 max_count = 1
#             }
#             triggerer {
#                 cpu = 0.5
#                 memory_gb = 1                
#                 count = 1
#             }
#         }
#     }
#     depends_on = [
#         google_project_iam_member.composer_worker,
#         google_kms_crypto_key.composer_key,
#         google_kms_crypto_key_iam_member.composer_service_agent_kms_access,
#         google_kms_crypto_key_iam_member.gcs_service_agent_kms_access
#     ]
# }