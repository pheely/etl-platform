# Create a Custom VPC

## Grant permissions

```bash
gcloud projects add-iam-policy-binding py-host-01 \
--member "user:host01@pycloudlabs.cc" \
--role roles/compute.networkAdmin

# Required to delete the default firewall rules
gcloud projects add-iam-policy-binding py-host-01 \
--member "user:host01@pycloudlabs.cc" \
--role roles/compute.securityAdmin
```

## Remove the `default` VPC

```bash
gcloud compute firewall-rules delete \
default-allow-rdp \
default-allow-ssh \
default-allow-internal \
default-allow-icmp \
--project=py-host-01

gcloud compute networks delete default
```

## Create a custom-mode VPC network

```bash
gcloud compute networks create py-workload-vpc \
    --subnet-mode=custom \
    --bgp-routing-mode=regional
```

## Create a custom subnet to the network

```bash
gcloud compute networks subnets create py-workload-nane1 \
    --network=py-workload-vpc \
    --region=northamerica-northeast1 \
    --range=10.0.1.0/24

gcloud compute networks subnets create py-workload-nane2 \
    --network=py-workload-vpc \
    --region=northamerica-northeast2 \
    --range=10.0.2.0/24
```

## Enable PGA

```bash
gcloud compute networks subnets update py-workload-nane1 \
--region=northamerica-northeast1 \
--enable-private-ip-google-access

gcloud compute networks subnets update py-workload-nane2 \
--region=northamerica-northeast2 \
--enable-private-ip-google-access


