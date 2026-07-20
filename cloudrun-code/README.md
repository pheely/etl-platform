# Cloud Run Python Code

## Virtual Environment

```bash
python -m venv my_env
source my_env/bin/activate
pip install -r requirements.txt
```

## Tests

```bash
python -m unittest discover -s test -p "test_*.py"
```

## Configure Docker Authentication

```bash
gcloud auth configure-docker northamerica-northeast1-docker.pkg.dev
```


## Build Container Image

```
VERSION="v3"
IMAGE="northamerica-northeast1-docker.pkg.dev/py-service-01/etl/composer-trigger:${VERSION}"
docker build --platform linux/amd64 -t ${IMAGE} .
docker push ${IMAGE}
```

## Deploy Service

Modify the image version in the [terraform code](../tf-code/service-project/cloud_run_service.tf). Then run

```bash
terraform apply -var 'create_composer_v3=true'
```

## Test

```bash
SERVICE_URL=$(gcloud run services describe composer-trigger-service \
  --platform managed \
  --region northamerica-northeast1 \
  --format 'value(status.url)')

curl -X POST "${SERVICE_URL}/trigger-dataproc-dag" \
  -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  -H "Content-Type: application/json"
```


```bash
TOKEN=$(gcloud auth print-identity-token \
  --impersonate-service-account=py-service-01-cloudrun-sa@py-service-01.iam.gserviceaccount.com \
  --audiences=https://5eaa404140e04fc1ac120a476b7efb14-dot-northamerica-northeast1.composer.googleusercontent.com)

curl -X POST \
https://5eaa404140e04fc1ac120a476b7efb14-dot-northamerica-northeast1.composer.googleusercontent.com/airflow/api/v2/dags/dataproc_serverless_production_pipeline/dagRuns \
-H "Content-Type: application/json" \
-H "Authorization: Bearer ${TOKEN}" \
-d '{
    "dag_run_id": "manual__2026-07-19T12:00:00",
    "conf": {
      "example_key": "example_value"
    }
  }'

TOKEN=$(gcloud auth print-identity-token \
  --impersonate-service-account=py-service-01-cloudrun-sa@py-service-01.iam.gserviceaccount.com \
  --audiences=https://5eaa404140e04fc1ac120a476b7efb14-dot-northamerica-northeast1.composer.googleusercontent.com)

echo "$TOKEN" | cut -d. -f2 | python3 -c "import sys, base64, json; print(base64.urlsafe_b64decode(sys.stdin.read() + '===').decode())" | jq

TOKEN2=$(gcloud auth print-identity-token)
echo "$TOKEN2" | cut -d. -f2 | python3 -c "import sys, base64, json; print(base64.urlsafe_b64decode(sys.stdin.read() + '===').decode())" | jq
```