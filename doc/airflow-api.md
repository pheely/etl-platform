# Triggering DAG via Airflow REST API

The goal is that when a file is dropped into a GCS bucket, A Cloud Run service will be triggered via eventarc. The Cloud Run service would trigger a DAG by invoking Airflow API.

## Endpoint

A DAG run can be triggered by a HTTP POST request to the following endpoint:

https://${COMPOSER_WEB_SERVER_URL}/api/v2/dags/{dag_id}/dagRuns

where
- COMPOSER_WEB_SERVER_URL is the Airflow webserver's URL.
- {dag_id} is the ID of the DAG to be triggered.

`COMPOSER_WEB_SERVER_URL` can be obtainer using

```bash
gcloud composer environments describe composer-nane1 \
--location northamerica-northeast1 \
--format "value(config.airflowUri)"
```

Note: do not use the value of `airflowByoidUri`.

## Identity

An OAuth2 access token is required in the request header. In CLI, it can be obrained using

```bash
gcloud auth print-access-token
```

In Python, it can be obrained from Cloud Run's metadata server using

```python
CREDENTIALS, _ = google.auth.default(scopes=AUTH_SCOPES)
```

The principal - Cloud Run service account in this case - should have the `roles/composer.user` role on GCP side.

On Airflow side, an matching user and RBAC should exist in its user database. The principal is identified in the form of `accounts.google.com:NUMERIC_USER_ID`. The `NUMERIC_USER_ID` is the OAuth2 Client ID associated with a GCP account (user account or service account). You can get it using the following command:

```bash
# for user account
TOKEN=$(gcloud auth print-access-token);curl "https://oauth2.googleapis.com/tokeninfo?access_token=${TOKEN}"

# for service accounts
gcloud iam service-accounts describe cloudrun-sa@py-service-01.iam.gserviceaccount.com --format="value(oauth2ClientId)"
```

A RBAC is required for each identity. See [Accessing Airflow UI](doc/airflow-ui.md) on how to set it up.

## Eventarc

Under the hood, GCS sends file event notifications via Cloud Storage directly to Eventarc. For this flow to work cleanly, three critical IAM bindings are included in the code:

1. GCS Service Agent - `pubsub.publisher`: Allows GCS to publish event notifications to Eventarc's internal transport mechanism.
2. Eventarc Service Account - `eventarc.eventReceiver`: Grants the trigger identity permission to receive events.
3. Eventarc Service Account - `run.invoker`: Grants the trigger identity permission to invoke the Cloud Run service.

Another note: Eventarc only supports HTTP POST. When its destination of Eventarc is a Cloud Run service, make sure your endpoint supports HTTP POST.
