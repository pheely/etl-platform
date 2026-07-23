import datetime
from airflow import models
from airflow.providers.google.cloud.operators.dataproc import DataprocCreateBatchOperator
from google.cloud import storage

# --- Core Platform Configurations ---
PROJECT_ID = "py-service-01"
REGION = "northamerica-northeast1"
SUBNETWORK_URI = f"projects/py-host-01/regions/{REGION}/subnetworks/dataproc-subnet-nane1"

# --- Identities & Security Configurations ---
# The specific service account you assigned the Dataproc Worker role to
CUSTOM_SERVICE_ACCOUNT = f"dataproc-sa@{PROJECT_ID}.iam.gserviceaccount.com"

# The CMEK resource string used to encrypt the ephemeral cluster resources
KMS_KEY_URI = f"projects/{PROJECT_ID}/locations/{REGION}/keyRings/dataproc-key-ring/cryptoKeys/dataproc-key"

# --- Storage Artifact Locations ---
GCS_BUCKET_NAME = "py-service-01-etl-code"
GCS_BUCKET = f"gs://{GCS_BUCKET_NAME}"
MAIN_PYTHON_FILE = f"{GCS_BUCKET}/scripts/main.py"
ARCHIVE_BLOB_PATH = "dependencies/my_env.tar.gz"

# --- Input/output Storage Locations ---
INPUT_BUCKET = "gs://py-service-01-etl-input"
OUTPUT_BUCKET = "gs://py-service-01-etl-output"


def get_runtime_properties():
    """Dynamically determines Spark properties based on requirements_runtime.txt state."""
    # Enforce autoscaling limit to safeguard your calculated subnet size
    base_properties = {
        "spark.dynamicAllocation.maxExecutors": "25"
    }

    # Check if a custom virtual environment bundle exists on GCS
    storage_client = storage.Client()
    bucket = storage_client.bucket(GCS_BUCKET_NAME)
    blob = bucket.blob(ARCHIVE_BLOB_PATH)

    if blob.exists():
        # Inject paths needed to mount and extract your custom dependencies
        base_properties["spark.archives"] = f"{GCS_BUCKET}/{ARCHIVE_BLOB_PATH}#environment"
        # Uses the safe Dataproc property layout instead of framework-level overrides
        base_properties["spark.dataproc.pyspark.executable"] = "./environment/bin/python"

    return base_properties


DEFAULT_ARGS = {
    "owner": "data-engineering",
    "start_date": datetime.datetime(2026, 1, 1),
    "depends_on_past": False,
    "retries": 1,
    "retry_delay": datetime.timedelta(minutes=5),
}

with models.DAG(
    dag_id="dataproc_serverless_production_pipeline",
    default_args=DEFAULT_ARGS,
    schedule="@daily",
    catchup=False,
    tags=["dataproc", "serverless", "production", "cmek"],
) as dag:

    submit_spark_batch = DataprocCreateBatchOperator(
        task_id="execute_pyspark_batch",
        project_id=PROJECT_ID,
        region=REGION,
        # Note: batch_id is safely auto-generated as a UUID if omitted here
        batch={
            "pyspark_batch": {
                "main_python_file_uri": MAIN_PYTHON_FILE,
                # Arguments passed directly to main.py's argparse processor
                "args": [
                    "--input", f"{INPUT_BUCKET}/names.csv",
                    "--output", f"{OUTPUT_BUCKET}/last_names",
                    "--write_mode", "overwrite",
                    "--input_format", "csv"
                ],
            },
            "environment_config": {
                "execution_config": {
                    "subnetwork_uri": SUBNETWORK_URI,      # Routes to your isolated subnet footprint
                    "service_account": CUSTOM_SERVICE_ACCOUNT,  # Avoids default Compute Engine SA bloat
                    "network_tags": ["pga"],               # Matches your narrow Cloud DNS/Firewall ALLOW rule
                    # Explicitly provision the job using your Customer-Managed Encryption Key
                    "kms_key": KMS_KEY_URI,
                },
            },
            "runtime_config": {
                "properties": get_runtime_properties(),
            },
        },
    )

