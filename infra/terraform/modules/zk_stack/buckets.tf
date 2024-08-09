# Buckets
resource "google_storage_bucket" "object-store-dev" {
  name          = var.object_store_bucket_name
  location      = upper(var.region)

  uniform_bucket_level_access = true

  public_access_prevention = "enforced"
}

resource "google_storage_bucket" "public-object-store-dev" {
  name          = var.public_object_store_bucket_name
  location      = upper(var.region)

  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "prover-object-store-dev" {
  name          = var.prover_object_store_bucket_name
  location      = upper(var.region)

  uniform_bucket_level_access = true

  public_access_prevention = "enforced"
}

resource "google_storage_bucket" "snapshots-object-store-dev" {
  name          = var.snapshots_object_store_bucket_name
  location      = upper(var.region)

  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "prover-setup-data" {
  name          = var.prover_setup_data_bucket_name
  location      = upper(var.region)

  uniform_bucket_level_access = true
}

# Public read access
resource "google_storage_bucket_iam_member" "public-object-store-dev-public-access" {
  bucket   = google_storage_bucket.public-object-store-dev.name
  role     = "roles/storage.objectViewer"
  member   = "allUsers"
}

resource "google_storage_bucket_iam_member" "snapshots-object-store-dev-public-access" {
  bucket   = google_storage_bucket.snapshots-object-store-dev.name
  role     = "roles/storage.objectViewer"
  member   = "allUsers"
}

# Bind k8s service account to buckets permissions
locals {
  buckets_buckets_k8s_service_account_namespace = "default"
  buckets_k8s_service_account_name              = "buckets-rw"
  buckets_k8s_service_account_principal         = "principal://iam.googleapis.com/projects/${data.google_project.zksync.number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/${local.buckets_buckets_k8s_service_account_namespace}/sa/${local.buckets_k8s_service_account_name}"
}

resource "kubernetes_service_account" "buckets-rw" {
  metadata {
    name = local.buckets_k8s_service_account_name
  }
}

resource "google_storage_bucket_iam_binding" "object-store-dev" {
  bucket = google_storage_bucket.object-store-dev.name
  role = "roles/storage.objectUser"
  members = [
    local.buckets_k8s_service_account_principal,
  ]
}

resource "google_storage_bucket_iam_binding" "public-object-store-dev" {
  bucket = google_storage_bucket.public-object-store-dev.name
  role = "roles/storage.objectUser"
  members = [
    local.buckets_k8s_service_account_principal,
  ]
}

resource "google_storage_bucket_iam_binding" "prover-object-store-dev" {
  bucket = google_storage_bucket.prover-object-store-dev.name
  role = "roles/storage.objectUser"
  members = [
    local.buckets_k8s_service_account_principal,
  ]
}

resource "google_storage_bucket_iam_binding" "snapshots-object-store-dev" {
  bucket = google_storage_bucket.snapshots-object-store-dev.name
  role = "roles/storage.objectUser"
  members = [
    local.buckets_k8s_service_account_principal,
  ]
}

resource "google_storage_bucket_iam_binding" "prover-setup-data" {
  bucket = google_storage_bucket.prover-setup-data.name
  role = "roles/storage.objectUser"
  members = [
    local.buckets_k8s_service_account_principal,
  ]
}
