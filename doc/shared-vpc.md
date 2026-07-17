# Configure a Share VPC

A Shared VPC is configured at the **Organization** or **Folder** level. The process involves designating one project as the **Host Project** (which hosts the actual VPC network and subnets) and linking other projects to it as **Service Projects** (which use those subnets to spin up resources like VMs or GKE clusters).

## Permissions Required to Set Up a Shared VPC

The following IAM roles are required across different levels of your Google Cloud hierarchy:

### For the Network Administrator (The person setting up the Shared VPC)

To enable the host project, attach service projects, and define subnet sharing, you must have **Shared VPC Admin** (`roles/compute.xpnAdmin`) role assigned at the **Organization** or **Folder** level.

### For the Service Project Admins / Developers (The people using the subnets)

To allow developers in a service project to actually deploy VMs or GKE clusters into the shared subnets, they need access to the subnet resource in the host project:

* **Role:** **Compute Network User** (`roles/compute.networkUser`)
* *Where to grant it:* Granted on the **Host Project** (either to the entire project or restricted to individual shared subnets) to the Service Project's service accounts or user groups.

---

## Step-by-Step Configuration

**Step 1: Grant Role**

```bash
# for folder nonp

gcloud resource-manager folders add-iam-policy-binding 159970908758 \
--member "user:host01@pycloudlabs.cc" \
--role roles/compute.xpnAdmin
```

**Step 2: Enable the Host Project**

```bash
gcloud compute shared-vpc enable py-host-01

```

**Step 3: Attach the Service Project to the Host**

```bash
gcloud compute shared-vpc associated-projects add py-service-01 \
    --host-project=py-host-01

```
