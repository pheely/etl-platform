COMPOSER_DAG_BUCKET=$(gcloud composer environments describe composer-nane1 \
    --project="py-service-01" \
    --location="northamerica-northeast1" \
    --format="value(config.dagGcsPrefix)")
echo "=== Cloud Composer DAG bucket: ${COMPOSER_DAG_BUCKET} ==="
echo "=== Syncing Airflow DAG to Cloud Composer ==="
gcloud storage cp dags/dataproc_serverless_dag.py "${COMPOSER_DAG_BUCKET}/dataproc_serverless_dag.py"

echo "=== Deployment successful! ==="