# Cloud Lab Environment for ETL Platform

This repo contains code for provisioning necessary cloud resources to support a platform that can run any Spark batch jobs.

The platform is running on Google Cloud Platform with a share VPC under a VPC service perimeter.

A sample pyspark job is used to validate the infrastructure.

Current status: the DAG can be triggered manually via Airflow UI or calling Airflow API directly. The Cloud Run triggering the DAG by calling Airflow API is not working due to a 403 issues - see [this](./cloudrun-code/README.md) for details.

[Set up an organization](doc/organization.md)

[Create Google Identities](doc/identity.md)

[Set up a VPC Service Controls](doc/vpcsc.md)

[Grant Users Viewer Role](doc/viewer.md)

[Configure a Share VPC](doc/shared-vpc.md)

[Create a Custom VPC](doc/vpc.md)

[Creating Resources required for Dataproc Serverless Batch](doc/dataproc-resources.md)

[Create a DAG for Dataproc Serverless Batch](doc/dag.md)

[Set up Subnets for Cloud Composer](doc/composer-subnet.md)

[Firewall Rules for Private Cloud Composer Environment](doc/firewall-composer.md)

[Accessing Airflow UI](doc/airflow-ui.md)

[Triggering DAG Run via Airflow REST API](doc/airflow-api.md)
