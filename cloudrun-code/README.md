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
VERSION="v2"
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

#### Principal: `admin@pycloudlabs.cc`

```bash
curl -X POST "https://f3cc5bb0e516408fbe0852fcdde2bb10-dot-northamerica-northeast1.composer.googleusercontent.com/api/v2/dags/dataproc_serverless_production_pipeline/dagRuns" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $(gcloud auth print-access-token)" \
-d '{
    "dag_run_id":"manual__2026-07-21T12-00-00",
    "logical_date": "2026-07-23T21:00:00Z",
    "conf": {}
  }'
```

Response:

```json
{"dag_run_id":"manual__2026-07-23T12-00-00","dag_id":"dataproc_serverless_production_pipeline","logical_date":"2026-07-23T21:00:00Z","queued_at":"2026-07-23T20:30:40.316914Z","start_date":null,"end_date":null,"duration":null,"data_interval_start":"2026-07-23T21:00:00Z","data_interval_end":"2026-07-23T21:00:00Z","run_after":"2026-07-23T20:30:40.268725Z","last_scheduling_decision":null,"run_type":"manual","state":"queued","triggered_by":"rest_api","triggering_user_name":"accounts.google.com:102913931299711603490","conf":{},"note":null,"dag_versions":[{"id":"019f90a0-4d86-703a-89c9-27977a98ba54","version_number":1,"dag_id":"dataproc_serverless_production_pipeline","bundle_name":"dags-folder","bundle_version":null,"created_at":"2026-07-23T20:17:32.550241Z","dag_display_name":"dataproc_serverless_production_pipeline","bundle_url":null}],"bundle_version":null,"dag_display_name":"dataproc_serverless_production_pipeline"}
```

#### Impersonating the cloud run service account.

```bash
# POST
SA_TOKEN=$(gcloud auth print-access-token --impersonate-service-account=cloudrun-sa@py-service-01.iam.gserviceaccount.com)

curl -X POST "https://f3cc5bb0e516408fbe0852fcdde2bb10-dot-northamerica-northeast1.composer.googleusercontent.com/api/v2/dags/dataproc_serverless_production_pipeline/dagRuns" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer ${SA_TOKEN}" \
-d '{
    "dag_run_id":"manual__2026-07-23T12-00-99",
    "logical_date": "2026-07-22T21:00:00Z",
    "conf": {}
  }'

# GET
SA_TOKEN=$(gcloud auth print-access-token --impersonate-service-account=cloudrun-sa@py-service-01.iam.gserviceaccount.com)

curl "https://f3cc5bb0e516408fbe0852fcdde2bb10-dot-northamerica-northeast1.composer.googleusercontent.com/api/v2/version" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer ${SA_TOKEN}"
```

### Callling Cloud Run Service which Calls Airflow API

#### HTTP POST

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

Error from Cloud Run code

```json
{
  "message": "403 Client Error: Forbidden for url: https://7a97e724987b4c05af7e5e2d2ea77dda-dot-northamerica-northeast1.composer.googleusercontent.com/api/v2/dags/dataproc_serverless_production_pipeline/dagRuns",
  "status": "ERROR"
}
```

The actual response from GCP:
- Status: 403
- Body:
    ```html
    <!DOCTYPE html>
    <html lang=en>
    <meta charset=utf-8>
    <meta name=viewport content="initial-scale=1, minimum-scale=1, width=device-width">
    </title>
    <style>
    *{margin:0;padding:0}html,code{font:15px/22px arial,sans-serif}html{background:#fff;color:#222;padding:15px}body{margin:7% auto 0;max-width:390px;min-height:180px;padding:30px 0 15px}* > body{background:url(//www.google.com/images/errors/robot.png) 100% 5px no-repeat;padding-right:205px}p{margin:11px 0 22px;overflow:hidden}ins{color:#777;text-decoration:none}a img{border:0}@media screen and (max-width:772px){body{background:none;margin-top:0;max-width:none;padding-right:0}}#logo{background:url(//www.google.com/images/logos/errorpage/error_logo-150x54.png) no-repeat;margin-left:-5px}@media only screen and (min-resolution:192dpi){#logo{background:url(//www.google.com/images/logos/errorpage/error_logo-150x54-2x.png) no-repeat 0% 0%/100% 100%;-moz-border-image:url(//www.google.com/images/logos/errorpage/error_logo-150x54-2x.png) 0}}@media only screen and (-webkit-min-device-pixel-ratio:2){#logo{background:url(//www.google.com/images/logos/errorpage/error_logo-150x54-2x.png) no-repeat;-webkit-background-size:100% 100%}}#logo{display:inline-block;height:54px;width:150px}
    </style>
    <a href=//www.google.com/><span id=logo aria-label=Google></span></a>
    <p><b>403.</b> <ins>That’s an error.</ins>
    <p> <ins>That’s all we know.</ins>
    ```

#### HTTP GET

```bash
SERVICE_URL=$(gcloud run services describe composer-trigger-service \
  --platform managed \
  --region northamerica-northeast1 \
  --format 'value(status.url)')

curl "${SERVICE_URL}/" \
  -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  -H "Content-Type: application/json"
```

Same error as POST
