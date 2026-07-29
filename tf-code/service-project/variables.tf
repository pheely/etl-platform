variable "project_id" {
  description = "The project ID to deploy to"
  type        = string
  default     = "py-service-01"
}

variable "region" {
  description = "The region to deploy to"
  type        = string
  default     = "northamerica-northeast1"
}

variable "composer_service_account_id" {
  description = "The service account ID for the Cloud Composer environment"
  type        = string
  default     = "py-service-01-composer-sa"
}

variable "host_project_id" {
  description = "The host project ID for the shared VPC"
  type        = string
  default     = "py-host-01"
}

variable "composer_kms_key_ring_name" {
  description = "The name of the KMS key ring for the Cloud Composer environment"
  type        = string
  default     = "composer-keyring"
}

variable "composer_kms_key_name" {
  description = "The name of the KMS key for the Cloud Composer environment"
  type        = string
  default     = "composer-key"
}

variable "composer_env_name" {
  description = "The name of the Cloud Composer environment"
  type        = string
  default     = "composer-env"
}

variable "airflow_ui_allowed_ip_ranges" {
  description = "A list of allowed IP ranges for accessing the Airflow UI"
  type = list(object({
    cidr        = string
    description = string
  }))
  default = [
    {
      cidr = "0.0.0.0/0"
      description = "allow all"
    },
    {
      cidr        = "209.29.168.27/32"
      description = "My Galaxy IP"
    },
    {
      cidr        = "99.229.154.65/32"
      description = "My Home IP"
    },
  ]
}

variable "composer_image_version" {
  description = "The image version for the Cloud Composer environment"
  type        = string
  default     = "composer-3-airflow-3.1.7"
}

variable "subnetwork" {
  description = "The subnetwork for the Cloud Composer environment"
  type        = string
  default     = "projects/py-host-01/regions/northamerica-northeast1/subnetworks/py-workload-nane1"
}

variable "environment" {
  description = "The environment name for labeling resources"
  type        = string
  default     = "dev"
}

variable "create_composer_v3" {
  description = "If true, create the Composer v3 environment(s)."
  type        = bool
  default     = false
}

variable "dataproc_service_account_id" {
  description = "The service account ID for the Dataproc Serverless Batch"
  type        = string
  default     = "dataproc-sa"
}

variable "dataproc_code_bucket_name" {
  description = "The name of the GCS bucket for Dataproc code"
  type        = string
  default     = "py-service-01-etl-code"
}

variable "etl_input_bucket_name" {
  description = "The name of the GCS bucket for ETL input data"
  type        = string
  default     = "py-service-01-etl-input"
}

variable "etl_output_bucket_name" {
  description = "The name of the GCS bucket for ETL output data"
  type        = string
  default     = "py-service-01-etl-output"
}

variable "dataproc_key_ring_name" {
  description = "The name of the KMS key ring for Dataproc"
  type        = string
  default     = "dataproc-key-ring"
}

variable "dataproc_key_name" {
  description = "The name of the KMS key for Dataproc"
  type        = string
  default     = "dataproc-key"
}

variable "etl_job_status_pubsub_topic_name" {
  description = "The name of the Pub/Sub topic for ETL job status"
  type        = string
  default     = "etl-job-status"
}

variable "cloudrun_service_account_id" {
  description = "The id of Cloud Run service account"
  type        = string
  default     = "cloudrun-sa"
}

variable "artifact_registry_id" {
  description = "The name of GAR"
  type        = string
  default     = "etl"
}

variable "artifact_registry_keyring_name" {
  description = "The name of GAR keyring"
  type        = string
  default     = "ar_keyring"
}

variable "artifact_registry_key_name" {
  description = "The name of GAR key"
  type        = string
  default     = "ar_key"
}

variable "etl_job_status_subscription_name" {
  description = "ETL job status pubsub subscription"
  type = string
  default = "etl_status_sub"
}