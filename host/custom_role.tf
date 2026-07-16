resource "google_project_iam_custom_role" "composer_environment_creator" {
  project     = var.project_id
  role_id     = "composerEnvironmentCreator"
  title       = "Composer Environment Creator"
  description = "Allows users to create and manage Cloud Composer environments."
  permissions = [
    # Network attachment management
    "compute.networkAttachments.create",
    "compute.networkAttachments.get",
    "compute.networkAttachments.delete",
    "compute.networkAttachments.update",

    # Basic subnet and network access
    "compute.subnetworks.get",
    "compute.subnetworks.use",
    "compute.networks.get",
    "compute.networks.access",

    # Basic discovery
    "compute.regions.get",
    "compute.zones.get",

    # DNS zone peering
    "dns.managedZones.get",
    # "dns.managedZones.list",
    "dns.networks.targetWithPeeringZone"
  ]

  stage = "BETA"
}