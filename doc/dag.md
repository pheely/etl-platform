# Create a DAG for Dataproc Serverless Batch

Dataproc Serverless Batch will be presented as an Airflow DAG. When a DAG run is triggered, the `DataprocCreateBatchOperator` will be creating a Dataproc serverless batch job. That DAG also contains a callback when the batch job is done. The callback will use `PubSubPublishMessageOperator` to publish a job notification message into a Pubsub topic.

See [this](../airflow-code/dags/dataproc_serverless_dag.py) for details.