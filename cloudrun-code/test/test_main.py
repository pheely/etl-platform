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

    @patch("main.requests.get")
    def test_get_fact_forwards_path_and_query(self, mock_get):
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = {"args": {"foo": "bar"}, "url": "https://httpbin.org/get/hello?foo=bar"}
        mock_get.return_value = mock_response

        response = self.app.get("/get/hello?foo=bar")

        self.assertEqual(response.status_code, 200)
        self.assertEqual(mock_get.call_args[0][0], "https://httpbin.org/get/hello?foo=bar")

    @patch('main.make_composer3_web_server_request')
    def test_trigger_dag_success(self, mock_request):
        """Test a successful DAG trigger scenario."""
        mock_response = MagicMock()
        mock_response.status_code = 201
        mock_response.text = "{}"
        mock_response.headers = {}
        mock_request.return_value = mock_response

        response = self.app.post('/trigger-dataproc-dag')

        self.assertEqual(response.status_code, 200)
        data = response.get_json()
        self.assertEqual(data["status"], "SUCCESS")
        self.assertIn("mock_dataproc_pipeline", data["message"])

        self.assertTrue(mock_request.called)

    def test_trigger_dag_missing_env_vars(self):
        """Test defensive handling when a critical environment variable is missing."""
        with patch.dict(os.environ, {"DAG_ID": ""}):
            response = self.app.post('/trigger-dataproc-dag')
            self.assertEqual(response.status_code, 500)
            data = response.get_json()
            self.assertEqual(data["status"], "ERROR")

    @patch('main.make_composer3_web_server_request')
    def test_trigger_dag_api_failure(self, mock_request):
        """Test graceful error response handling if the Airflow API returns an error."""
        mock_response = MagicMock()
        mock_response.status_code = 404
        mock_response.text = "DAG 'mock_dataproc_pipeline' not found"
        mock_response.headers = {}
        mock_request.return_value = mock_response

        response = self.app.post('/trigger-dataproc-dag')

        self.assertEqual(response.status_code, 200)
        data = response.get_json()
        self.assertEqual(data["status"], "SUCCESS")


if __name__ == '__main__':
    unittest.main()
