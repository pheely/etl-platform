# Accessing Airflow UI

Access to Airflow UI is controlled by two components:
- Cloud IAM
- Airflow RBAC

## Airflow URL

```bash
gcloud composer environments describe composer-nane1 --location northamerica-northeast1 --format "value(config.airflowUri)"
```

## Default Access

It seems that any GCP user account can access Airflow UI due to context-aware access (TBC). When the "Open Airflow UI" link in GCP console is clicked, you will be prompted to choose the account to access Airflow. By default, the `Op` role is assigned to the account.

https://accounts.google.com/signin/oauth/id?authuser=0&part=AJi8hANJwUugybK5JNx6JqE-pBdWcon3FH-ARaAW7hzJ_Ui-BDb5bYipDv99j_Esh1l6lQpggh3WTS4yiIt0yqTVVe4T59dQGh7jyPPdlYzAi-YTqRFor5PXLmg1DOW1Iq62RnGb56AAifrTM43Q9QMoP7ANYQb6Pc9jCHbvfq_e1bKKunMXgRLhTTA9SX3z7zctPD1tQukjPaRdwQZiTUrUyRX9gGraptXgrEDt6X0abMxSovBJvvPzGES-QYzjIu-krZmFxR0YeSkE10bqCD296FQmHThwfD7KwCrAQzGcGSmaFVFi69am0bXv3OXg_TbIx0W1cih2GuI9z-h1wKkd7cNR6WRfIZZI49YVIAwS4nmIlCFLoMBYUqj3h8QhVmG63AejwxhpbPFdorfllGPZYzraKJLm2pbT15JWux2qLG180Whr24r-k0I_LS-wfwkFeinCA7poQiy-GWtMjqJRI66Vfxoumsd-GIIv1zbDtrs6KhBesBxDxLv65U0YDIjmbPSNqUQKH-eBoWtwG9whqYiihE2bS-fJsZEp4hvB52-EC9YSUstMb86gtOK6yjUlqZjDxKIMHVMm-X3S9_MX3AJbPdqvLWnbWYKwowuXUuAp4RPFRT_3Z57x_gvshs5k5NJzW3EwZjT1_vCB-pfcXS0qlFDEkyRI11Nfuw3_i3X-Oe09A4aeScV7EejeJL00jBc2nrO9onoyJLrnouY3D-z__J0VkRiuLnN42aDCniFlSa2H5XgrB3X4_KpEFWgQH0snxvm_nUx27c4YJZaXvYxenbbZz-c0ao0GUC5YUzVBpqnnclI&flowName=GeneralOAuthFlow&as=S-1473802206%3A1784736032803004&client_id=431403837536-q0odo3nmtfjocv7q291cnmedr0hnlbkh.apps.googleusercontent.com&rapt=AEjHL4OYYRVm22wihMq7WeMZ9sTyQPT8lfbRlWCjeo1S0_ckdnLCLyQyg02UGaIUoO5ELb88l-zpgEG27ULpkiyE0pn9WFeJe7KRbX_Hj6xyJzIPcs9rvlI#


Use the following command to list the users that have access to Airflow:
```bash
gcloud composer environments run composer-nane1 \
  --location northamerica-northeast1 users list
```

The result should be something like the following:

```text
id | username                                  | email                    | first_name               | last_name | roles
===+===========================================+==========================+==========================+===========+=========
1  | accounts.google.com:102913931299711603490 | admin@pycloudlabs.cc     | admin@pycloudlabs.cc     | -         | Op
```

Notice that the `username` has the form of `accounts.google.com:NUMERIC_USER_ID`. The `NUMERIC_USER_ID` is the OAuth2 Client ID associated with a GCP account (user account or service account). You can get it using the following command:

```bash
# for user account
gcloud auth print-identity-token | python3 -c "import sys, json, base64; token=sys.stdin.read().split('.')[1]; print(json.loads(base64.b64decode(token + '=' * (-len(token) % 4)).decode('utf-8'))['sub'])"

# or
TOKEN=$(gcloud auth print-identity-token);curl "https://oauth2.googleapis.com/tokeninfo?id_token=${TOKEN}" | grep sub

# or
TOKEN=$(gcloud auth print-access-token);curl "https://oauth2.googleapis.com/tokeninfo?access_token=${TOKEN}"


# for service accounts
gcloud iam service-accounts describe cloudrun-sa@py-service-01.iam.gserviceaccount.com --format="value(oauth2ClientId)"
```

## Bootstap `Admin` User

To bootstrap a user with the `Admin` role, run the following command with an account that has the `roles/composer.admin` role:
```bash
gcloud composer environments run composer-nane1 \
--location northamerica-northeast1 \
users add-role -- -e "admin@pycloudlabs.cc" -r Admin
```
or
```bash
gcloud composer environments run composer-nane1 \
  --location northamerica-northeast1 \
  users add-role -- \
  -u "accounts.google.com:102913931299711603490" \
  -r Admin
```

When a user with the `Admin` role sign in to Airflow UI, a `Security` menu will show on the left navigation. The the Admin can manage users and roles in Airflow's RBAC system.

>**Note**: If you encounter an error indicating `users` is not a valid subcommand of `gcloud composer environments run` for Composer 3.1.7, please upgrade your gcloud CLI

## User/Role Adminsitration

This can be done via the Airflow UI in the `Security` menu, or use the following command:

```bash
# Add a user into Airflow RBAC
gcloud composer environments run composer-nane1 \
  --location northamerica-northeast1 \
  users create -- \
  -r Admin \
  -e "cloudrun-sa@py-service-01.iam.gserviceaccount.com" \
  -u "accounts.google.com:118161481744136252904" \
  -f "CloudRunSA" \
  -l "-" \
  --use-random-password

# Add a role to an existing user
gcloud composer environments run composer-nane1 \
    --location northamerica-northeast1 \
    users add-role -- \
    -r Op \
    -e "cloudrun-sa@py-service-01.iam.gserviceaccount.com"

gcloud composer environments run composer-nane1 \
    --location northamerica-northeast1 \
    users add-role -- \
    -r User \
    -e "cloudrun-sa@py-service-01.iam.gserviceaccount.com"
```


## Tip: How to Inspect a Google OAuth 2.0 Access Token

```bash
curl "https://oauth2.googleapis.com/tokeninfo?access_token=ya29.c.c0AZ4bNpbxJZQ5TqFKcElg2-CPTCxjzH4xf1Uxe9TUR05kwDgqQJNDzQ6sdii4er7iaJRf3IVujh1YiXmtdTL1x5bx44LH-ikL6CYaCweZb01cGn4qGEviBSBl8JZt8QpOeJOKEGxBDCGFsWTloaJ98IYYJUKFwJLdlsJMheDITZLZhNs9RQQ9cRqratYeylWepwPw7h1DLzffS1gLYEdWu8khzltTDYab83bxp9xrEpB_A8rP7SdyBl3kzmv9EWCiabL9qntLn9AX5-7lqMEfUY_TePWOwv0wSr-Z7HMgadqPiAI8q913LvM-LWLO7qhsZzz63y0zDLLhMdv8FRn6wx1hcERoc9jemn3Z8Dki64IsI6vtKDlogJbfyrDPFVtzEJ4vvGMYfW8jCNoul5kV-QQXMrDImJBawPWRIUtFYSyhsKk6pvQC0l4y3A8d-QT455KQko4sXbizRv_ds9ylft_14Y28I_b03m_xvZeZ1MolrV1U_gwSpdQie1-6IMnxZrfUwp4o2I8YsV9Oy69xBO3wFlpj4rlWype8RsvI6z-uSagS5WofYgtZUtf6wzvXIwsem61Ba3lBzJR5kXt2B_BUe6ruZdowagvOqbi6eyS76ucJFeve5jxoo3JIp8liYUsgVy0xsqRXakcMWkFVzxsp5ZQjf3n7_c9S5xXi3Uor1lkZfZBVxahB5her42jgaXOkkJ_sua-j2bBqV-cI2FJ25Qh87gq4n-nybBjg2R63qcOIl3-fYogkklaUjcXccgwary2xIYrehabjFp-aur3tWYfIaOX-1gp41mpUikifmuxoYdanem6rsd9Jjpk0bhtXxYgezSnw1_Msb7B8J9b6jSXyvzx1_6W5W0g3oSxY1Wvhuh3ybRgI0-9gi8Yitmnu2mgmcRtg8ugRnOaOvYa6kV_Wvu2Ih0O-QF8z5UZQMkpI80SYS9BvfZZYQYliRJaB6klBcdwRIs6UM8jukp_z7WvVtIq2srS9me8Ij1OIRhsQ-F6xdYQ"
{
  "azp": "107753901527766502729",
  "aud": "107753901527766502729",
  "scope": "https://www.googleapis.com/auth/cloud-platform",
  "exp": "1784747397",
  "expires_in": "1244",
  "access_type": "online"
}
```
