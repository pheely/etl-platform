data "google_compute_network" "myvpc" {
  name = "py-workload-vpc"
  project = var.project_id
}

# 1. Create the Private DNS Zone for googleapis.com
resource "google_dns_managed_zone" "googleapis_private_zone" {
  name        = "private-googleapis-zone"
  project     = var.project_id
  dns_name    = "googleapis.com."
  description = "Private zone to force Dataproc/Composer PGA traffic to restricted VIPs"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = data.google_compute_network.myvpc.self_link
    }
  }
}

# 2. Add the A Records mapping private.googleapis.com to the PGA IP addresses
resource "google_dns_record_set" "private_googleapis_a" {
  name         = "private.googleapis.com."
  project      = var.project_id
  managed_zone = google_dns_managed_zone.googleapis_private_zone.name
  type         = "A"
  ttl          = 300

  # The exact 4 IP addresses designated for private.googleapis.com
  rrdatas = [
    "199.36.153.8",
    "199.36.153.9",
    "199.36.153.10",
    "199.36.153.11"
  ]
}

# 3. Add a wildcard CNAME record directing *.googleapis.com to private.googleapis.com
resource "google_dns_record_set" "googleapis_cname" {
  name         = "*.googleapis.com."
  project      = var.project_id
  managed_zone = google_dns_managed_zone.googleapis_private_zone.name
  type         = "CNAME"
  ttl          = 300

  rrdatas = ["private.googleapis.com."]
}