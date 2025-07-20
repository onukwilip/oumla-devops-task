resource "google_service_account" "k8s_sa" {
  account_id   = "oumla-k8s-sa"
  display_name = "Oumla Kubernetes Cluster Service Account"
}

# Bind multiple IAM roles to the service account
resource "google_project_iam_member" "k8s_sa_roles" {
  for_each = toset([
    "roles/compute.admin",
    "roles/storage.admin",
    "roles/iam.serviceAccountUser",
    "roles/compute.networkAdmin",
    "roles/compute.loadBalancerAdmin",
    "roles/serviceusage.serviceUsageViewer",
    "roles/viewer",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/logging.logWriter"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.k8s_sa.email}"
}
