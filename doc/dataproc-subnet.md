# Set up Subnets for Dataproc Serverless

## Sizing Formula
Each Dataproc Serverless batch job consists of:

* **1 Driver node** (Always 1 IP)
* **Executors (Worker) nodes** (Variable IPs based on scaling)

By default, Dataproc Serverless enables Spark Dynamic Resource Allocation (autoscaling). A single batch job starts with a minimum of 2 executors (requiring 2 IPs) but can dynamically scale up to a maximum number of executors.

> $$\text{Max IPs per Job} = 1\text{ (Driver)} + \text{Maximum Executors For That Job}$$ 

For example, if a job is configured to scale up to a maximum of 20 executors, that single job can consume up to **21 IP addresses** at its peak.

To find the absolute maximum number of IP addresses required at any given moment, use the following formula:

$$\text{Total Required IPs} = \sum_{i=1}^{N} \left( 1 + \text{Max Executors for Job } i \right) + \text{GCP Reserved IPs}$$

Where:

* **$N$** = The maximum number of Dataproc Serverless batch jobs running **concurrently** at peak time.
* **GCP Reserved IPs** = Google Cloud automatically reserves **4 IP addresses** in every subnet (the network address, default gateway, an internal reserved IP, and the broadcast address).

## Scenario Example

If you plan to run **10 concurrent batch jobs** at midnight, and each job is capped at a maximum of **25 executors**:

* IPs per job = $1 + 25 = 26 \text{ IPs}$
* IPs for 10 jobs = $26 \times 10 = 260 \text{ IPs}$
* Plus GCP reservation = $260 + 4 = 264 \text{ IPs}$

## Map to CIDR Blocks

Once you have your total IP count, map it to a standard CIDR block prefix. It is always recommended to include a **50% buffer** to prevent job failures caused by IP exhaustion during unexpected data spikes or when adding new pipelines.

| CIDR Prefix | Total IPs Provided | Usable IPs (Minus 4 GCP Reserved) | Best For... |
| --- | --- | --- | --- |
| **`/26`** | 64 | 60 | Small development/testing environments. |
| **`/24`** | 256 | 252 | Moderate production workloads (e.g., 10 concurrent small jobs). |
| **`/23`** | 512 | 508 | Standard enterprise data platform subnet. |
| **`/22`** | 1024 | 1020 | Heavy, parallel enterprise batch processing. |

*For the 264 IP example above, a `/24` (252 usable IPs) would fall short, so you would need to carve out a **`/23`** subnet.*

## Architectural Best Practices

* **Isolate Dataproc via VPC/Subnet:** Since Dataproc Serverless can quickly consume hundreds of IPs during heavy auto-scaling, carve out a dedicated subnet exclusively for it. This prevents Dataproc from exhausting IP spaces needed by critical, long-running infrastructure (like GKE clusters or transactional databases).
* **Enforce Max Executors Globally or via Templates:** To prevent a single poorly optimized Spark job from stealing all available IPs in your subnet, always set a strict ceiling using Dataproc Runtime Templates or by explicitly passing the property upon submission:
`--properties spark.dynamicAllocation.maxExecutors=X`
* **Enable Private Google Access:** This is a **strict prerequisite** for Dataproc Serverless. Because the instances do not have public IPs, they must use Private Google Access to talk to Cloud Storage, BigQuery, and other Google APIs.
* **Cross-VPC Communication (Private NAT):** If your dedicated Dataproc subnet is sitting in a separate VPC to save internal corporate IP space, you can use **Network Connectivity Center (NCC)** paired with a **Private Cloud NAT** to route traffic back into your core network using only a tiny, predetermined pool of IPs (e.g., a `/28`).