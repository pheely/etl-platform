## Creating an Organization in Google Cloud Platform

Setting up a completely free Google Cloud Organization using **Cloud Identity Free** is a highly effective way to unlock enterprise features like Shared VPCs, Folders, and VPC Service Controls.

Here is the step-by-step blueprint to build your organization:

### Step 1: Secure a Custom Domain Name

An Organization resource maps directly to a domain suffix. If you do not already own a domain name (like `yoursandbox.com`), you will need to buy one.

* Go to a domain registrar (such as Squarespace Domains, GoDaddy, Namecheap, or Cloudflare).
* Purchase a cheap domain name. You can often find extensions like `.xyz`, `.dev`, `.cc`, or `.info` for just a few dollars a year.

I purchased `pycloudlabs.cc` for $8/year.

### Step 2: Sign Up for Cloud Identity Free

Instead of signing up for Google Workspace (which requires a paid monthly license for business email), you will use the hidden free identity tier.

* Open an Incognito window and navigate to https://workspace.google.com/gcpidentity/signup?sku=identitybasic.
* Enter your basic details and select **Next**.
* When prompted for your business domain, select **Yes, I have one that I can use** and type in the custom domain you purchased in Step 1.
* Create your primary admin user account (e.g., `admin@pycloudlabs.cc`) and choose a secure password (`topSecretGood4Now!`).

### Step 3: Verify Your Domain Ownership

To protect infrastructure security, Google forces you to prove you own the domain before it builds your cloud directories.

* You will be automatically redirected to the **Google Admin Console** (`admin.google.com`). Log in with your newly created admin credentials.
* Follow the on-screen Setup Wizard prompts to **Verify Domain Ownership**.
* The wizard will give you a specific string of characters called a **TXT Record**.
* Log into cloudflare.com, find the DNS Management section, and add a new TXT record pasting Google's verification string.
* Return to the Google Admin Console and click **Verify**. It may take a couple of minutes for DNS records to propagate.

### Step 4: Access Your New GCP Organization

After your domain identity is verified, wait 15 minutes or so for your top-level Organization resource is created at the backend. 

Once that background provisioning notification clears, you are officially ready to interact with your root Organization container. Accessing it correctly changes how you navigate the Google Cloud Console, shifting from isolated projects to a structural enterprise view.

Here is the exact deep dive into navigating, verifying, and securing your brand-new `pycloudlabs.cc` root environment.

#### 1. Interacting with the Enterprise Scope Picker

Go to the [Google Cloud Console](https://console.cloud.google.com/). Make sure you sign in using your new custom domain account (`admin@pycloudlabs.cc`).

The primary change you will notice is in the **Project Selector** dropdown menu at the very top of the Google Cloud console (right next to the main "Google Cloud" branding text).

1. Click on the dropdown. A modal window titled **Select a project** will appear.
2. In the top-left of this modal window, you will see a field explicitly labeled **Select from:** or **Organization**.
3. Click that drop-down option and switch it from *No organization* to **`pycloudlabs.cc`**.

Once selected, the window changes to show you only the folders and projects nested inside your corporate directory boundary. Standalone projects attached to personal `@gmail.com` accounts will live outside of this view.

#### 2. Navigating the Resource Manager Dash

To get a full tree-view of your new hierarchy, head straight to the central directory hub:

* In the search bar at the top of the console, type **Manage Resources** and select the top matching page (or navigate via the menu to **IAM & Admin** > **Manage Resources**).

From here, you are looking directly at the root of your technical infrastructure. You will see:

* The **`pycloudlabs.cc`** root node at the absolute top, accompanied by a unique, permanent numeric **Organization ID**.
* Any initial project you created during the bootstrap phase nested directly beneath it.

#### 3. Immediate Recommended Actions

Now that you have root entry, you want to perform two critical tasks to prepare the environment for your enterprise testing (like Shared VPCs and VPC Service Controls):

##### A. Secure Your IAM Bindings

By default, the account that creates the Cloud Identity directory is granted sweeping capabilities, but it's important to verify you have the explicit metadata management roles bound at the root level:

1. Check the checkbox right next to the `pycloudlabs.cc` row on the **Manage Resources** page.
2. On the right-hand side of the screen, an **Info Panel** will expand displaying current permissions.
3. Verify that your `admin@pycloudlabs.cc` principal is explicitly granted the **Resource Manager > Organization Administrator** role.

##### B. Build Out Your Base Folder Topography

Enterprise setups rarely put projects directly under the root organization node. Instead, they segregate environments using Folders to cleanly manage IAM inheritance and VPC SC perimeters.

To create folders, you need to grant the folder creator role to the admin account. 

1. Make sure you are on the Manage Resources page in the GCP Console.
2. In the project/scope drop-down menu at the very top of the page, verify that your organization `pycloudlabs.cc` is explicitly selected.
3. In the main table on the page, find the row for `pycloudlabs.cc` (the one with the building/domain icon at the absolute top of the tree) and check the box next to it.
4. Look over to the right side of your screen. The Info Panel will slide open. If it doesn't appear, click the Show Info Panel button in the upper right.
5. Click **Add Principal** at the top of that right-hand panel.
6. Configure the following fields:
   - New principals: Type your full admin email address: `admin@pycloudlabs.cc`
   - Role: Navigate to Resource Manager > Folder Creator (or just search for Folder Creator in the filter box).

Right here on the Manage Resources page, click **Create Folder** at the top and create a logical structural hierarchy for your upcoming networking and security tests. A standard sandbox layout looks like this:

```text
pycloudlabs.cc (Root Organization)
 ├── 📁 enterprise  
         ├── 📁 nonp   
         └── 📁 prod
```
