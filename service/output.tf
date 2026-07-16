output "composer_environment_ids" {
  description = "Cloud Composer environment IDs."
  value = {
    for k, env in module.composer_v3 :
    k => env.composer_env_id
  }
}

output "composer_environment_names" {
  description = "Cloud Composer environment names."
  value = {
    for k, env in module.composer_v3 :
    k => env.composer_env_name
  }
}

output "composer_airflow_uris" {
  description = "Airflow UI URIs."
  value = {
    for k, env in module.composer_v3 :
    k => env.airflow_uri
  }
}

output "composer_gcs_buckets" {
  description = "Composer DAG buckets."
  value = {
    for k, env in module.composer_v3 :
    k => env.gcs_bucket
  }
}