"""
Trigger a DAG in Cloud Composer 3 environment with Airflow 3 using the Airflow REST API v2.
"""

from __future__ import annotations

from typing import Any

import os
import google.auth
from google.auth import impersonated_credentials
from google.auth.transport.requests import AuthorizedSession, Request
import requests
import flask
from datetime import datetime, timezone

# Following best practices, these credentials should be
# constructed at start-up time and used throughout
# https://cloud.google.com/apis/docs/client-libraries-best-practices
AUTH_SCOPES = [
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/userinfo.email",
    "openid"
]

CREDENTIALS, _ = google.auth.default(scopes=AUTH_SCOPES)

# For debugging 403 issue, remove it later
CREDENTIALS.refresh(Request())
print(f">>>DEBUG: cred.email: {CREDENTIALS.service_account_email}")
print(f"credential type: {type(CREDENTIALS)}")

# source_creds, _ = google.auth.default()
# target_creds = impersonated_credentials.Credentials(
#     source_credentials=source_creds,
#     target_principal="cloudrun-sa@py-service-01.iam.gserviceaccount.com",
#     target_scopes=[AUTH_SCOPE],
#     lifetime=3600,
# )
# End of debugging code


def make_composer3_web_server_request(
    url: str, method: str = "GET", **kwargs: Any
) -> google.auth.transport.Response:
    """
    Make a request to Cloud Composer 3 environment's web server with Airflow 3.
    Args:
      url: The URL to fetch.
      method: The request method to use ('GET', 'OPTIONS', 'HEAD', 'POST', 'PUT',
        'PATCH', 'DELETE')
      **kwargs: Any of the parameters defined for the request function:
                https://github.com/requests/requests/blob/master/requests/api.py
                  If no timeout is provided, it is set to 90 by default.
    """

    authed_session = AuthorizedSession(CREDENTIALS)

    # debugging code
    # authed_session = AuthorizedSession(target_creds)
    # end of debugging code

    # Set the default timeout, if missing
    if "timeout" not in kwargs:
        kwargs["timeout"] = 90

    resp = authed_session.request(method, url, **kwargs)

    print(f">>>DEBUG: endpoint url: {url}")
    print(f">>>DEBUG: scopes: {authed_session.credentials.scopes}")
    print(f">>>DEBUG: token: {authed_session.credentials.token}")
    print(f">>>DEBUG: Transmitted Headers: {dict(resp.request.headers)}")

    return resp


def trigger_dag(web_server_url: str, dag_id: str, data: dict, logical_date: str, dag_run_id: str) -> str:
    """
    Make a request to trigger a DAG using the Airflow REST API v2.
    https://airflow.apache.org/docs/apache-airflow/stable/stable-rest-api-ref.html

    Args:
      web_server_url: The URL of the Airflow 3 web server.
      dag_id: The DAG ID.
      data: Additional configuration parameters for the DAG run (json).
    """

    endpoint = f"api/v2/dags/{dag_id}/dagRuns"
    request_url = f"{web_server_url}/{endpoint}"
    json_data = {"dag_run_id": f"manual__{dag_run_id}", "conf": data, "logical_date": logical_date}

    response = make_composer3_web_server_request(
        request_url, method="POST", json=json_data
    )

    if response.status_code != 201:
        print(f">>>DEBUG: STATUS: {response.status_code}")
        print(f">>>DEBUG: BODY: {response.text}")
        print(f">>>DEBUG: HEADERS: {response.headers}")
        response.raise_for_status()
    else:
        return response.text


app = flask.Flask(__name__)


@app.route("/trigger-dataproc-dag", methods=["POST"])
def trigger():
    # COMPOSER_WEB_SERVER_URL is passed in as an ENV value. It is the
    # Airflow web server address. To obtain this
    # URL, run the following command for your environment:
    # gcloud composer environments describe example-environment \
    #  --location=your-composer-region \
    #  --format="value(config.airflowUri)"
    COMPOSER_WEB_SERVER_URL = os.environ.get("COMPOSER_WEB_SERVER_URL")
    DAG_ID = os.environ.get("DAG_ID", "dataproc_serverless_production_pipeline")

    if not COMPOSER_WEB_SERVER_URL or not DAG_ID:
        return flask.jsonify({
            "status": "ERROR",
            "message": "Missing critical environment variables: COMPOSER_WEB_SERVER_URL or DAG_ID."
        }), 500

    # Replace with configuration parameters for the DAG run.
    dag_config = {
        "your-key": "your-value"
    }

    # Replace with the data interval for which to run the DAG
    logical_date = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    dag_run_id = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H-%M-%SZ")

    try:
        return trigger_dag(
            web_server_url=COMPOSER_WEB_SERVER_URL,
            dag_id=DAG_ID,
            data=dag_config,
            logical_date=logical_date,
            dag_run_id=dag_run_id
        )
    except Exception as e:
        return flask.jsonify({"status": "ERROR", "message": str(e)}), 500


@app.route("/", defaults={"path": ""})
@app.route("/<path:path>")
def composer_get(path):
    target_path = path if path else "version"

    COMPOSER_WEB_SERVER_URL = os.environ.get("COMPOSER_WEB_SERVER_URL")

    if not COMPOSER_WEB_SERVER_URL:
        return flask.jsonify({
            "status": "ERROR",
            "message": "Missing critical environment variables: COMPOSER_WEB_SERVER_URL."
        }), 500

    endpoint = f"api/v2/{target_path}"
    request_url = f"{COMPOSER_WEB_SERVER_URL}/{endpoint}"

    response = make_composer3_web_server_request(request_url, method="GET")

    if response.status_code != 200:
        print(f">>>DEBUG: STATUS: {response.status_code}")
        print(f">>>DEBUG: BODY: {response.text}")
        print(f">>>DEBUG: HEADERS: {response.headers}")
        response.raise_for_status()
    else:
        return response.text
