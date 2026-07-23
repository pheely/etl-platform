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

```bash
VERSION="v1"
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

### Call Airflow REST API Directly

Principal: `admin@pycloudlabs.cc`

```bash
curl -X POST "https://7a97e724987b4c05af7e5e2d2ea77dda-dot-northamerica-northeast1.composer.googleusercontent.com/api/v2/dags/dataproc_serverless_production_pipeline/dagRuns" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $(gcloud auth print-access-token)" \
-d '{
    "dag_run_id":"manual__2026-07-23T12-00-00",
    "logical_date": "2026-07-23T21:00:00Z",
    "conf": {}
  }'
```

Response:

```json
{"dag_run_id":"manual__2026-07-23T12-00-00","dag_id":"dataproc_serverless_production_pipeline","logical_date":"2026-07-23T21:00:00Z","queued_at":"2026-07-23T20:30:40.316914Z","start_date":null,"end_date":null,"duration":null,"data_interval_start":"2026-07-23T21:00:00Z","data_interval_end":"2026-07-23T21:00:00Z","run_after":"2026-07-23T20:30:40.268725Z","last_scheduling_decision":null,"run_type":"manual","state":"queued","triggered_by":"rest_api","triggering_user_name":"accounts.google.com:102913931299711603490","conf":{},"note":null,"dag_versions":[{"id":"019f90a0-4d86-703a-89c9-27977a98ba54","version_number":1,"dag_id":"dataproc_serverless_production_pipeline","bundle_name":"dags-folder","bundle_version":null,"created_at":"2026-07-23T20:17:32.550241Z","dag_display_name":"dataproc_serverless_production_pipeline","bundle_url":null}],"bundle_version":null,"dag_display_name":"dataproc_serverless_production_pipeline"}
```

It also works when impersonate the cloud run service account.

```bash
SA_TOKEN=$(gcloud auth print-access-token --impersonate-service-account=cloudrun-sa@py-service-01.iam.gserviceaccount.com)

curl -X POST "https://7a97e724987b4c05af7e5e2d2ea77dda-dot-northamerica-northeast1.composer.googleusercontent.com/api/v2/dags/dataproc_serverless_production_pipeline/dagRuns" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer ${SA_TOKEN}" \
-d '{
    "dag_run_id":"manual__2026-07-23T12-00-99",
    "logical_date": "2026-07-22T21:00:00Z",
    "conf": {}
  }'
```

### Callling Cloud Run Service which Calls Airflow API

Principal: `admin@pycloudlabs.cc`

```bash
SERVICE_URL=$(gcloud run services describe composer-trigger-service \
  --platform managed \
  --region northamerica-northeast1 \
  --format 'value(status.url)')

curl -X POST "${SERVICE_URL}/trigger-dataproc-dag" \
  -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  -H "Content-Type: application/json"
```

Error

```json
{
  "message": "403 Client Error: Forbidden for url: https://7a97e724987b4c05af7e5e2d2ea77dda-dot-northamerica-northeast1.composer.googleusercontent.com/api/v2/dags/dataproc_serverless_production_pipeline/dagRuns",
  "status": "ERROR"
}
```

