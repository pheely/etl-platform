# Subnetwork for Cloud Composer

The networking architecture of Cloud Composer 3 has been fundamentally simplified compared to Cloud Composer 2. Cloud Composer 3 leverages a fully managed architecture connected via PSC instead of standard VPC Peering and massive GKE-native subnet deployments, the IP address footprints required from your VPC are remarkably small.

Cloud Composer 3 reserves **2** IP addresses in your primary subnet and dynamically uses **2** additional IP addresses during background maintenance and upgrades. We only need **4** free IP addresses per environment.

If we are carving out a dedicated subnet for Composer, a **`/29`** (8 IPs, 3 usable after GCP reserves 5) is technically the bare minimum to support those 4 usable IPs. However, to account for standard GCP subnet overhead (such as the gateway, metadata, and broadcast IPs), **a `/28`** (16 IPs) or **`/27`** (32 IPs) is the safest and most standard "micro" size to reserve for a dedicated Composer subnet.

Unlike Cloud Composer 2, we do **not** need to configure or carve out secondary IP ranges (Alias IPs) for Kubernetes pods or services in your VPC subnet.

**The Internal (Tenant-Side) IP Range**

Even though your local VPC subnet is tiny, the backend components of your managed Airflow environment (such as the tenant-side GKE cluster and Cloud SQL proxy) still need a block of internal IP addresses to communicate with each other in Google's tenant project.

This range **must use a `/20` mask** (4,096 addresses). If you don't specify one, GCP defaults this range to `100.64.128.0/20`. This `/20` range **cannot overlap** with your primary VPC subnetwork range or any other connected ranges. If you need to custom-define this block to avoid collisions with your corporate network, you can set it to `cloud_composer_connection_subnetwork` in the Terraform code as follows:

```hcl
resource "google_composer_environment" "composer_v3" {
  name   = "my-composer-v3-env"
  region = "us-central1"

  config {
    # Composer 3 is defined by setting the active_version to a v3 image
    software_config {
      image_version = "composer-3-airflow-2.10.5-build.23" 
    }

    # Pass your tiny /28 subnet here
    node_config {
      network    = "projects/your-project/global/networks/your-vpc-name"
      subnetwork = "projects/your-project/regions/us-central1/subnetworks/your-composer-subnet"
    }

    # Pass your custom /20 tenant-side range here
    private_environment_config {
      enable_private_environment           = true
      cloud_composer_connection_subnetwork = "10.198.0.0/20"
    }
  }
}
```

>**Note**: Google's composer module does not expose this variable in the `create_environment_v3` submodule as of 6.4.0
