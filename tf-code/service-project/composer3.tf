module "composer_v3" {
  for_each = var.create_composer_v3 ? local.composer_envs : {}

  source  = "terraform-google-modules/composer/google//modules/create_environment_v3"
  version = "6.4.0"

  image_version            = var.composer_image_version
  project_id               = var.project_id
  network_project_id       = var.host_project_id
  composer_env_name        = each.value.env_name
  region                   = each.value.region
  composer_service_account = google_service_account.composer_sa.email

  # Private-only Composer 3
  use_private_environment = true

  airflow_config_overrides = {
    "api-composer_auth_user_registration_role" = "Admin"
    "core-default_ui_timezone" = "America/Toronto"
    "webserver-default_ui_timezone" = "America/Toronto"
  }

  # Let the module create the PSC network attachment
  create_network_attachment        = true
  composer_network_attachment_name = each.value.network_attachment_name

  # VPC and subnet used by the Composer network attachment
  network    = local.network_name
  subnetwork = each.value.subnetwork_name

  # Keep dependency builds private-only
  # Important when you do not want PyPI/package build traffic to use public internet
  enable_private_builds_only = true
  environment_size           = "ENVIRONMENT_SIZE_SMALL"

  kms_key_name = google_kms_crypto_key.composer_key.id

  scheduler = {
    cpu        = 0.5
    memory_gb  = 2
    storage_gb = 1
    count      = 2
  }

  dag_processor = {
    cpu        = 0.5
    memory_gb  = 2
    storage_gb = 1
    count      = 2
  }

  web_server = {
    cpu        = 0.5
    memory_gb  = 2
    storage_gb = 1
  }

  web_server_network_access_control = [for range in var.airflow_ui_allowed_ip_ranges : {
    allowed_ip_range = range.cidr
    description      = range.description
  }]

  worker = {
    cpu        = 0.5
    memory_gb  = 2
    storage_gb = 5
    min_count  = 2
    max_count  = 4
  }

  triggerer = {
    cpu       = 0.5
    memory_gb = 2
    count     = 1
  }

  labels = local.labels

  depends_on = [
    google_project_service.apis,
    google_project_iam_member.composer_worker,
  ]
}