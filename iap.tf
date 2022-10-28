locals {
  google_apis = toset(["iap.googleapis.com"])
}

resource "google_project_service" "default" {
  for_each                   = local.google_apis
  service                    = each.value
  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_iap_web_iam_member" "default" {
  for_each = toset(var.accessors)
  role     = "roles/iap.httpsResourceAccessor"
  member   = "user:${each.value}"

  depends_on = [
    google_project_service.default
  ]
}


