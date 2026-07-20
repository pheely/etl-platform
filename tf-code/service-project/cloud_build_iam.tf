# ## Revoke this after the CI/CD service account is set up

# # ====================================================================
# # 1. Human Operator Permissions (admin@pycloudlabs.cc)
# # ====================================================================

# resource "google_project_iam_member" "admin_cloudbuild_editor" {
#   project = var.project_id
#   role    = "roles/cloudbuild.builds.editor"
#   member  = "user:admin@pycloudlabs.cc"
# }

# resource "google_project_iam_member" "admin_storage_admin" {
#   project = var.project_id
#   role    = "roles/storage.objectAdmin"
#   member  = "user:admin@pycloudlabs.cc"
# }


# # ====================================================================
# # 2. Worker Execution Identity Permissions (Compute Default Service Account)
# # ====================================================================

# resource "google_project_iam_member" "compute_sa_cloudbuild_agent" {
#   project = var.project_id
#   role    = "roles/cloudbuild.serviceAgent"
#   member  = "serviceAccount:883388338180-compute@developer.gserviceaccount.com"
# }

# resource "google_project_iam_member" "compute_sa_storage_viewer" {
#   project = var.project_id
#   role    = "roles/storage.objectViewer"
#   member  = "serviceAccount:883388338180-compute@developer.gserviceaccount.com"
# }