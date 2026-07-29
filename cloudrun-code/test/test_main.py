import os
import sys
import unittest
from unittest.mock import patch, MagicMock, ANY

# 1. Ensure the 'src' directory is discoverable
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../src')))

# 2. Set up environment variables BEFORE importing the app (IAP_CLIENT_ID removed)
os.environ["COMPOSER_WEB_SERVER_URL"] = "https://mock-composer.googleusercontent.com"
os.environ["DAG_ID"] = "mock_dataproc_pipeline"

# 3. Import the app now that the environment is fully ready
# The '# noqa: E402' comment stops your linter from warning you about import placement
from main import app  # noqa: E402


class TestCloudRunTrigger(unittest.TestCase):

    def setUp(self):
        """Set up the Flask test client before each test execution."""
        self.app = app.test_client()
        self.app.testing = True

    @patch('main.get_composer_v3_token')
    @patch('main.requests.post')
    def test_trigger_dag_success(self, mock_post, mock_get_token):
        """Test a successful DAG trigger scenario."""
        # Mock the new internal function to return a formatted Bearer token
        mock_get_token.return_value = "Bearer mocked-oauth2-access-token-xyz"

        mock_response = MagicMock()
        mock_response.status_code = 201
        mock_response.json.return_value = {"dag_run_id": "manual__2026-07-18T12:00:00"}
        mock_post.return_value = mock_response

        response = self.app.post('/trigger-dataproc-dag')

        self.assertEqual(response.status_code, 201)
        data = response.get_json()
        self.assertEqual(data["status"], "SUCCESS")
        self.assertIn("mock_dataproc_pipeline", data["message"])

        # Verify the outward call contains the direct access token
        mock_post.assert_called_once_with(
            "https://mock-composer.googleusercontent.com/airflow/api/v1/dags/mock_dataproc_pipeline/dagRuns",
            headers={
                "Authorization": "Bearer mocked-oauth2-access-token-xyz",
                "Content-Type": "application/json"
            },
            json={
                "dag_run_id": ANY,
                "conf": {}}
        )

    def test_trigger_dag_missing_env_vars(self):
        """Test defensive handling when a critical environment variable is missing."""
        with patch.dict(os.environ, {"DAG_ID": ""}):
            with patch('main.DAG_ID', ""):
                response = self.app.post('/trigger-dataproc-dag')
                self.assertEqual(response.status_code, 500)
                data = response.get_json()
                self.assertEqual(data["status"], "ERROR")

    @patch('main.get_composer_v3_token')
    @patch('main.requests.post')
    def test_trigger_dag_api_failure(self, mock_post, mock_get_token):
        """Test graceful error response handling if the Airflow API returns an error."""
        mock_get_token.return_value = "Bearer mocked-oauth2-access-token-xyz"

        mock_response = MagicMock()
        mock_response.status_code = 404
        mock_response.text = "DAG 'mock_dataproc_pipeline' not found"
        mock_post.return_value = mock_response

        response = self.app.post('/trigger-dataproc-dag')

        self.assertEqual(response.status_code, 404)
        data = response.get_json()
        self.assertEqual(data["status"], "FAILED")


if __name__ == '__main__':
    unittest.main()
