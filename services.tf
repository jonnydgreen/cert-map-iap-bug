locals {
  regions = toset(["europe-west1", "us-central1"])
}

resource "google_cloud_run_service" "hello1" {
  for_each = local.regions

  name     = "hello1"
  location = each.value

  template {
    spec {
      containers {
        args    = []
        command = []
        image   = "us-docker.pkg.dev/cloudrun/container/hello"

        ports {
          container_port = 8080
          name           = "http1"
        }

        resources {
          limits = {
            "cpu"    = "1000m"
            "memory" = "512Mi"
          }
          requests = {}
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  metadata {
    annotations = {
      "run.googleapis.com/ingress" = "internal-and-cloud-load-balancing"
    }
  }
}

resource "google_cloud_run_service_iam_member" "noauth1" {
  for_each = google_cloud_run_service.hello1
  project  = google_cloud_run_service.hello1[each.key].project
  service  = google_cloud_run_service.hello1[each.key].name
  location = google_cloud_run_service.hello1[each.key].location

  role   = "roles/run.invoker"
  member = "allUsers"
}

output "hello1" {
  value = {
    for k, bd in google_cloud_run_service.hello1 : k => bd.status[0].url
  }
}

resource "google_cloud_run_service" "hello2" {
  for_each = local.regions

  name     = "hello2"
  location = each.value

  template {
    spec {
      containers {
        args    = []
        command = []
        image   = "us-docker.pkg.dev/cloudrun/container/hello"

        ports {
          container_port = 8080
          name           = "http1"
        }

        resources {
          limits = {
            "cpu"    = "1000m"
            "memory" = "512Mi"
          }
          requests = {}
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  metadata {
    annotations = {
      "run.googleapis.com/ingress" = "internal-and-cloud-load-balancing"
    }
  }
}

resource "google_cloud_run_service_iam_member" "noauth2" {
  for_each = google_cloud_run_service.hello2
  project  = google_cloud_run_service.hello2[each.key].project
  service  = google_cloud_run_service.hello2[each.key].name
  location = google_cloud_run_service.hello2[each.key].location

  role   = "roles/run.invoker"
  member = "allUsers"
}

output "hello2" {
  value = {
    for k, bd in google_cloud_run_service.hello2 : k => bd.status[0].url
  }
}
