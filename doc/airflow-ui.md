# Accessing Airflow UI

[Google document](https://docs.cloud.google.com/composer/docs/composer-3/access-airflow-web-interface)

>**The following statement requires validate. It seems that the IAP-secured Web App user role is not required.**
>
>Google Cloud secures the Airflow UI using Identity-Aware Proxy (IAP). Even if you are a Project Owner or Editor, you might lack the specific, explicit role required to pass through the IAP tunnel.
>
>You (or your GCP Organization Admin) must grant your Google account the IAP-secured Web App User role (`roles/iap.httpsResourceAccessor`).
>
>```bash
>gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
>    --member="user:your-email@company.com" \
>    --role="roles/iap.httpsResourceAccessor"
>```

To grant a user the Airflow Admin role in Google Cloud Composer v3, you must use the gcloud composer environments run command to execute the Airflow CLI. [1]

By default, when new users access the Airflow UI for the first time, they are automatically registered with a lower-level role (typically Op). An existing environment administrator must elevate their privileges. [1]

## Prerequisites
Before executing the command, ensure your Google Cloud identity has the necessary IAM permissions to execute Airflow commands on the cluster. Minimally, you need the Environment and Storage Object Administrator (roles/composer.environmentAndStorageObjectAdmin) and Service Account User (roles/iam.serviceAccountUser) roles. [2, 3, 4]


## Step-by-Step Instruction

   1. Open your terminal or activate Cloud Shell in the Google Cloud Console.
   2. Execute the following command to append the Admin role to the user's account: [5]

```bash
gcloud composer environments run composer-nane1 \
    --location northamerica-northeast1 \
    users add-role -- -e admin@pycloudlabs.cc -r Admin
```


## Keyword Definitions

* ENVIRONMENT_NAME: The exact name of your Composer v3 environment.
* LOCATION: The Compute Engine region where your environment is deployed (e.g., us-central1).
* USER_EMAIL: The full Google account or corporate email address of the user you want to promote. [1, 6]

Note: The -- separator is necessary to tell gcloud to pass the remaining flags (-e and -r) directly to the underlying Airflow CLI. [1]
If you need to view or manage your environments directly, you can check the status on the Google Cloud Composer Console. For a deeper look into security configurations, refer to the [Google Cloud Composer v3 Access Control Documentation](https://docs.cloud.google.com/composer/docs/composer-3/access-control). [7, 8, 9]
If you want to customize your setup further, let me know if you would like to:

* Change the default registration role for all new users
* Create custom roles with specific DAG-level permissions
* Verify a user's current roles using the CLI [1, 10]


[1] [https://docs.cloud.google.com](https://docs.cloud.google.com/composer/docs/composer-3/airflow-rbac)
[2] [https://docs.cloud.google.com](https://docs.cloud.google.com/composer/docs/composer-2/access-control)
[3] [https://discuss.google.dev](https://discuss.google.dev/t/cloud-composer-managing-cross-environment-dependencies/188743)
[4] [https://docs.cloud.google.com](https://docs.cloud.google.com/composer/docs/composer-3/run-apache-airflow-dag-gcloud)
[5] [https://docs.cloud.google.com](https://docs.cloud.google.com/composer/docs/composer-1/airflow-rbac)
[6] [https://docs.cloud.google.com](https://docs.cloud.google.com/composer/docs/composer-1/create-environments)
[7] [https://docs.cloud.google.com](https://docs.cloud.google.com/composer/docs/composer-3/access-airflow-web-interface)
[8] [https://docs.cloud.google.com](https://docs.cloud.google.com/composer/docs/composer-3/access-control)
[9] [https://medium.com](https://medium.com/@akhilasaineni7/triggering-google-cloud-composer-airflow-dags-via-the-rest-api-7d1c2999ac7e)
[10] [https://medium.com](https://medium.com/@sendoamoronta/isolation-and-access-control-between-teams-and-workloads-in-apache-airflow-and-cloud-composer-7ce1a0b22a3d)
