# Firewall Rules for Private Cloud Composer Environment

## Traffic Flow

```shell
+--------------------------+               +--------------------------------------+
|  Google Tenant Project   |               |         Your Consumer VPC            |
|                          |               |                                      |
|  [ Airflow Workers ]     |               |    [ Target Subnet ]                 |
|            |             |               |    (e.g., Database / VM)             |
|            |             |               |            ^                         |
|            v             |               |            |  [ Ingress Allow Rule ] |
|     (PSC Interface)      |               |            |  Source: 10.0.1.0/28    |
|            |             |               |            |  Port: Target Port      |
+------------|-------------+               +------------|-------------------------+
             |                                          |
             |  (Secure PSC Tunnel)                     |
             v                                          |
+------------|------------------------------------------|-------------------------+
|    [ Composer Subnet ] (e.g., 10.0.1.0/28)            |                         |
|                                                       |                         |
|    (PSC Network Attachment)                           |                         |
|    * Performs SNAT                                    |                         |
|    * Source IP becomes an IP in 10.0.1.0/28  ---------+                         |
+---------------------------------------------------------------------------------+
```

## Ingress

Because the environment is connected via PSC, no inbound firewall rules are needed in your VPC for Composer's internal operations. Traffic initiated by the managed tenant components enters your subnet securely through the PSC Network Attachment.

## Egress

### Connectivity to Google APIs

Your private Airflow workers need to reach Google services (such as Cloud Storage to sync DAGs and logs, Secret Manager, Cloud Logging, BigQuery, etc.).  

- Destination Range: 
  - For standard private IP: `199.36.153.8/30`(`private.googleapis.com`)
  - For private IP with VPCSC: `199.36.153.4/30` (`restricted.googleapis.com`)
- Ports: TCP `443` (HTTPS)
- Action: Allow

### Outbound to Local VPC Resources

If your DAGs need to interact with on-premises servers, databases, or VM instances running in other subnets of your VPC:

- Destination Range: The CIDR blocks of your target resources.
- Ports: The database or service port (e.g., TCP 5432 for PostgreSQL, 3306 for MySQL, etc.).
- Protocol: TCP

Another firewall rule on the receiving side is required to allow Airflow ingress.

- Direction: `INGRESS`
- Source: Composer's subnet CIDR
- Destination: target subnet that hosts the resources
- Protocols/Ports: specific ports (e.g., TCP `5432` for Postgres)
- Action: ALLOW

## What about the Airflow Web UI?

In Cloud Composer 3, the Airflow Web Server does not run inside your VPC; it is hosted in Google's tenant project and exposed via an external URL secured by Identity-Aware Proxy (IAP) and IAM. 

No VPC firewall rules is required. Instead, you control access to the Web UI using Web Server Network Access Control Levels (ACLs). You can configure these directly on the Composer environment via the Console, CLI, or Terraform to restrict access to specific corporate IP ranges (e.g., your office VPN public CIDR).  
