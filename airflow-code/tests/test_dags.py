import unittest
from unittest.mock import MagicMock, patch
from airflow.models import DagBag


class TestDataprocServerlessDag(unittest.TestCase):

    @patch('google.cloud.storage.Client')
    def setUp(self, mock_storage_client):
        """Sets up the local test environment by mocking the GCS check."""
        # Mock the GCS bucket and blob structures inside the DAG
        self.mock_client = mock_storage_client.return_value
        self.mock_bucket = MagicMock()
        self.mock_blob = MagicMock()

        self.mock_client.bucket.return_value = self.mock_bucket
        self.mock_bucket.blob.return_value = self.mock_blob

        # Scenario A: Simulate that the custom dependency archive does not exist
        self.mock_blob.exists.return_value = False

        # Load the DAG folder using Airflow's DagBag helper utility
        # Setting include_examples=False speeds up local processing time
        self.dagbag = DagBag(dag_folder='dags')

    def test_dag_loading_and_syntax(self):
        """Verifies that the DAG contains zero import errors or syntax flaws."""
        # Ensure that our target DAG parsed cleanly into the local DagBag
        dag_id = "dataproc_serverless_production_pipeline"
        self.assertIn(dag_id, self.dagbag.dags, f"DAG '{dag_id}' failed to load completely.")

        # Check that there are no structural import faults logged by the engine
        import_errors = self.dagbag.import_errors
        self.assertEqual(len(import_errors), 0, f"DAG import errors detected: {import_errors}")

    def test_task_configurations(self):
        """Validates operator structure and parameter assignments."""
        dag = self.dagbag.dags.get("dataproc_serverless_production_pipeline")
        task_id = "execute_pyspark_batch"

        # Check that the task exists within the execution graph
        self.assertIn(task_id, dag.task_ids, f"Task '{task_id}' is missing from the DAG.")
        task = dag.get_task(task_id)

        # Extract the underlying operator configurations
        batch_config = task.batch
        execution_config = batch_config.get("environment_config", {}).get("execution_config", {})

        # Validate that network tags match our target firewall exceptions
        self.assertIn("pga", execution_config.get("network_tags", []), "The 'pga' network tag is missing.")

        # Verify that a custom service account is assigned to bypass default credentials
        self.assertIsNotNone(execution_config.get("service_account"), "The custom service account is missing.")

        # Target the properly nested runtime_config sub-dictionary
        runtime_config = batch_config.get("runtime_config", {})
        self.assertIsNotNone(runtime_config, "runtime_config is missing.")

        self.assertIsNotNone(
            execution_config.get("kms_key"),
            "The Cloud KMS encryption key mapping is missing from runtime_config."
        )
        self.assertEqual(
            execution_config.get("kms_key"),
            "projects/py-service-01/locations/northamerica-northeast1/keyRings/dataproc-key-ring/cryptoKeys/dataproc-key"
        )


if __name__ == '__main__':
    unittest.main()
