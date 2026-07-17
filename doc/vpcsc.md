# Set up a VPC Service Controls

To protect an entire folder and all the projects beneath it using **VPC Service Controls (VPC SC)**, you need to configure an **Organization-level or Scoped Access Policy** and define a **Regular Service Perimeter**.

Because VPC Service Controls are enforced at the project level under the hood, adding a folder to a perimeter automatically includes all current and *future* projects created within that folder.

Here is the step-by-step guide to setting this up.

---

## Prerequisites & Permissions

Before you start, ensure you have the correct Identity and Access Management (IAM) roles at the **Organization** level. Standard project ownership is not enough to manage VPC SC.

* **Access Context Manager Admin** (`roles/accesscontextmanager.policyAdmin`) — Required to create and manage the service perimeter.
* **Organization Viewer** (`roles/resourcemanager.organizationViewer`) — Required to browse the resource hierarchy.

---

## Step-by-Step Implementation

### Step 1: Create an Access Policy (If you don't have one)

VPC Service Controls perimeters live inside an Access Policy. If your organization doesn't have an access policy yet, you must create one at the organization level.

Using the gcloud CLI:

```bash
gcloud access-context-manager policies create \
    --organization=YOUR_ORGANIZATION_ID \
    --title="Main Access Policy"
```

### Step 2: Define the Service Perimeter

You can create the perimeter via the Google Cloud Console or the `gcloud` CLI.

#### Method A: Using the Google Cloud Console

1. In the Google Cloud Console, switch to your **Organization** using the project/organization picker.
2. Navigate to **Security** > **VPC Service Controls**.
3. Click **New Perimeter**.
4. **Details:** Enter a name for your perimeter and leave the type as **Regular (default)**.
5. **Resources to Protect:** * Click **Add Resources**.
* Change the dropdown/filter from "Projects" to **Folders**.
* Select your target folder. This will automatically encompass all projects nested inside it.


6. **Restricted Services:** Select the Google Cloud APIs you want to protect (e.g., `storage.googleapis.com` for Cloud Storage, `bigquery.googleapis.com` for BigQuery).
7. **VPC Accessible Services (Optional):** Leave as "All services" unless you want to restrict which services can be reached from within your VPC networks.
8. Click **Create Perimeter**.

#### Method B: Using the `gcloud` CLI

To do this via the CLI, you will need the numeric **Folder ID**.

```bash
gcloud access-context-manager perimeters create YOUR_PERIMETER_NAME \
    --title="Folder Protection Perimeter" \
    --resources=folders/YOUR_FOLDER_ID \
    --restricted-services=storage.googleapis.com,bigquery.googleapis.com \
    --policy=YOUR_ACCESS_POLICY_ID
```

## Crucial Gotchas & Best Practices

> ⚠️ **Warning on Dry-Run Mode:** VPC Service Controls can instantly break existing applications, CI/CD pipelines, or developer access if configured incorrectly. **Always** create your perimeter in **Dry-Run mode** first.

* **Audit with Dry-Run:** When creating the perimeter in the console, select **Dry-Run** instead of Enforced. Monitor your Cloud Audit Logs for `VPC_SERVICE_CONTROLS_VIOLATION` errors to see what *would* have been blocked, adjust your rules, and only then flip it to **Enforced**.
* **Handling the Folder Boundaries:** If a service or user outside this folder attempts to access a protected BigQuery dataset or GCS bucket inside the folder, they will be blocked unless you explicitly configure **Ingress/Egress Rules** or **Access Levels** (e.g., allowing access based on corporate IP ranges or specific Service Accounts).
* **Automation:** If you manage your infrastructure via Terraform, utilize the `google_access_context_manager_service_perimeter` resource and pass `folders/YOUR_FOLDER_ID` into the `resources` list.

## Allow Request from Admin IP

1. Select the organization from the resource selection dropdown.
2. Search for "Access Context Manager"
3. Click "Create access level"
4. Enter "Admin_IP_Allowed" as the "Title"
5. Select "IP sunbetworks" from the "Conditions"
6. Choose "Public IP"
7. Enter the IP address (Google search "What's my IP Address) adding "/32"
8. Click "Save"
9. Go to "VPC Service Controls" and select your service perimeter from the list
10. Click "Edit"
11. Click "Access levels"
12. Click "Add access levels"
13. Check the checkbox beside "Admin_IP_Allowed"
14. Click "Save"

## Create an Ingress Rule to Allow Identity Access

1. Select the organization from the resource selection dropdown.
2. Go to "VPC Service Controls" and select your service perimeter from the list
3. Click "Edit"
4. Click "Ingress policy"
5. Select "Add an ingress rule"
6. Under "From > Identities", add desired users in the `user:email_address" format
7. Make sure "All sources" is selected under "From > Sources"
8. Click "Save"
