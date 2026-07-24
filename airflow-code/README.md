# Create DAG

## Test DAGs

```bash
python -v venv my_env
source my_env/bin/activate
pip install -r requirement.txt

python -m unittest discover -s tests -p "test_*.py"
```

## Deploy DAGs

```bash
COMPOSER_DAG_BUCKET=$(gcloud composer environments describe composer-nane1 \
    --project="py-service-01" \
    --location="northamerica-northeast1" \
    --format="value(config.dagGcsPrefix)")

echo "=== Syncing Airflow DAG to Cloud Composer ==="
gcloud storage cp dags/dataproc_serverless_dag.py "${COMPOSER_DAG_BUCKET}/dataproc_serverless_dag.py"

echo "=== Deployment successful! ==="
```



