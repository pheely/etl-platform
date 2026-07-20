import os
import jwt
import flask
import google.auth
import google.auth.transport.requests
from google.auth.compute_engine import Credentials as ComputeEngineCredentials
import requests
import json
from datetime import datetime
from google.auth.transport.requests import Request
from google.oauth2 import id_token

app = flask.Flask(__name__)

# COMPOSER_WEB_SERVER_URL = os.environ.get("COMPOSER_WEB_SERVER_URL")
COMPOSER_WEB_SERVER_URL = "https://5eaa404140e04fc1ac120a476b7efb14-dot-northamerica-northeast1.composer.googleusercontent.com"
DAG_ID = os.environ.get("DAG_ID", "dataproc_serverless_production_pipeline")


def get_id_token(audience):
    auth_req = Request()
    token = id_token.fetch_id_token(auth_req, audience)
    decoded = jwt.decode(token, options={"verify_signature": False})
    print(f">>> DEBUG: [99] decoded jwt: {decoded}")
    return token


def get_composer_v3_token() -> str:
    """Generates a standard Google OAuth 2.0 Access Token for Composer 3 authentication."""
    print(">>> DEBUG: [1] Initializing identity lookup via metadata channel...")

    try:
        # Explicitly target the instance metadata identity framework directly
        credentials = ComputeEngineCredentials(scopes=["https://www.googleapis.com/auth/cloud-platform"])
        print(">>> DEBUG: [2] Natively attached to serverless compute runtime engine.")
    except Exception as e:
        print(f">>> DEBUG: [!] Direct metadata interface unavailable, trying generic discovery: {e}")
        credentials, _ = google.auth.default(
            scopes=["https://www.googleapis.com/auth/cloud-platform"]
        )

    auth_request = google.auth.transport.requests.Request()
    print(">>> DEBUG: [3] Refreshing OAuth 2.0 Token via metadata channel...")
    credentials.refresh(auth_request)

    # FIXED: True email address string is populated ONLY after refresh() is executed
    runtime_email = getattr(credentials, "service_account_email", "Could not resolve email string")
    print(f">>> DEBUG: [4] Verified identity runtime account email: {runtime_email}")

    token_len = len(credentials.token) if credentials.token else 0
    print(f">>> DEBUG: [5] Token refresh complete. Token string length: {token_len} chars.")

    return f"Bearer {credentials.token}"


@app.route("/trigger-dataproc-dag", methods=["POST"])
def trigger_dag():
    print("\n>>> ==================== NEW TRIGGER REQUEST ====================")
    print(f">>> DEBUG: [6] Target URL env var: {COMPOSER_WEB_SERVER_URL}")
    print(f">>> DEBUG: [7] Target DAG ID: {DAG_ID}")

    if not COMPOSER_WEB_SERVER_URL or not DAG_ID:
        print(">>> DEBUG: [!] Error: Missing critical environment variables!")
        return flask.jsonify({
            "status": "ERROR",
            "message": "Missing critical environment variables: COMPOSER_WEB_SERVER_URL or DAG_ID."
        }), 500

    try:
        # 1. Fetch token
        # bearer_token = get_composer_v3_token()
        token = get_id_token(COMPOSER_WEB_SERVER_URL)

        # 2. Build explicit BYOID REST API target path
        endpoint_url = f"{COMPOSER_WEB_SERVER_URL}/airflow/api/v2/dags/{DAG_ID}/dagRuns"
        print(f">>> DEBUG: [8] Assembled Endpoint Target URI: {endpoint_url}")

        headers = {
            # "Authorization": bearer_token,
            "Authorization": token,
            "Content-Type": "application/json"
        }

        json_payload = {
            "dag_run_id": f"manual__{datetime.now().isoformat()}",
            "conf": {}
        }

        print(f">>> DEBUG: outgoing headers: {headers}")
        print(f">>> DEBUG: outgoing json_payload: {json.dumps(json_payload, indent=2)}")
        print(">>> DEBUG: [9] Launching downstream HTTP POST request to Composer Web Server...")
        response = requests.post(endpoint_url, headers=headers, json=json_payload)

        # 3. Collect response insights
        print(f">>> DEBUG: [10] Response Status Code received: {response.status_code}")
        print(f">>> DEBUG: [11] Response Headers: {dict(response.headers)}")
        print(f">>> DEBUG: [12] Raw Content Body Snippet: {response.text[:500]}")

        if response.status_code == 201:
            print(">>> DEBUG: [13] Match Success! 201 Created returned.")
            return flask.jsonify({
                "status": "SUCCESS",
                "message": f"Successfully triggered DAG '{DAG_ID}'",
                "details": response.json()
            }), 201
        else:
            print(f">>> DEBUG: [!] Failure State reached. Status Code: {response.status_code}")
            return flask.jsonify({
                "status": "FAILED",
                "status_code": response.status_code,
                "error": response.text
            }), response.status_code

    except Exception as e:
        print(f">>> DEBUG: [!!] Global Exception caught inside container: {str(e)}")
        return flask.jsonify({"status": "ERROR", "message": str(e)}), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
