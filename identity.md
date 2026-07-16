# Add Google Identities

## Add more email accounts in your domain in Cloudflare

1. Select "Account Home" at the left pane
2. Click the domain name under "Domains" in the main pane. The Left pane will be refreshed and the contents will change.
3. Click "Build > Email Service > Email Routing" in the left pane.
4. In the main pane, click "Destination Addresses" tab.
5. Type in your own personal email account address, and click "Add address"
6. Select "Routing rules" tab, then click "Create routing rule"
7. Provide an "Email pattern", e.g. `info`. And choose your domain name. Select "Send to an email" ad the Action. Select the email address provided in step 5 as the "Destination".
8. Click Save.

## Add the email accounts into Google Cloud

1. Go to https://admin.google.com
2. Sign in using the admin account and password
3. Select "Billing > Buy or upgrade > Cloud Identity > Cloud Identity Free". Make sure you subscribe the service.
4. Select "Directory > Users"
5. Click "Add new user"
6. Fill in all the fields with proper info. The secondary email address should be the personal email address you provided in step 5 of the previous section.
