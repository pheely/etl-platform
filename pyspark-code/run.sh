#!/bin/bash

# Configuration
PROJECT_ID="py-service-01"
REGION="northamerica-northeast1"
SUBNET="projects/py-host-01/regions/northamerica-northeast1/subnetworks/dataproc-subnet-nane1"
CODE_BUCKET="gs://py-service-01-etl-code"
INPUT_BUCKET="gs://py-service-01-etl-input"
OUTPUT_BUCKET="gs://py-service-01-etl-output"
BATCH_ID="pyspark-dep-job-$(date +%s)"
DATAPROC_SA="dataproc-sa@py-service-01.iam.gserviceaccount.com"
KMS_KEY_URI="projects/py-service-01/locations/northamerica-northeast1/keyRings/dataproc-key-ring/cryptoKeys/dataproc-key"
gcloud dataproc batches submit pyspark "${CODE_BUCKET}/scripts/main.py" \
    --project="${PROJECT_ID}" \
    --region="${REGION}" \
    --batch="${BATCH_ID}" \
    --subnet="${SUBNET}" \
    --tags="pga" \
    --ttl="10m" \
    --kms-key="${KMS_KEY_URI}" \
    --service-account="${DATAPROC_SA}" \
    --properties="spark.archives=${CODE_BUCKET}/dependencies/my_env.tar.gz\#environment" \
    --properties="spark.dataproc.pyspark.executable=./environment/bin/python" \
    -- \
    --input "${INPUT_BUCKET}/names.csv" \
    --output "${OUTPUT_BUCKET}/last_names" \
    --write_mode "overwrite" \
    --input_format "csv"