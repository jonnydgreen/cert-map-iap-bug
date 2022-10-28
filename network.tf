module "cert" {
  project      = var.project_id
  source       = "github.com/TyeMcQueen/terraform-google-certificate-map-simple?ref=v0.2.4"
  dns-zone-ref = var.name
  map-name1    = "${var.name}-com"
  hostnames1   = ["hello1", "hello2"]
}

locals {
  lb_be_config = {
    description             = null
    enable_cdn              = false
    custom_request_headers  = null
    custom_response_headers = null

    iap_config = {
      enable               = var.enable_iap
      oauth2_client_id     = var.oauth2_client_id
      oauth2_client_secret = var.oauth2_client_secret
    }

    security_policy = null

    log_config = {
      enable      = true
      sample_rate = 1.0
    }
  }
}

module "lb-http" {
  source  = "./modules/lb-http"
  name    = "hello"
  project = var.project_id

  ssl                  = true
  use_ssl_certificates = true
  certificate_map      = module.cert.map-id1[0]
  https_redirect       = true

  url_map        = google_compute_url_map.hello.self_link
  create_url_map = false

  backends = {
    hello1 = merge(local.lb_be_config, {
      groups = [
        for v in google_compute_region_network_endpoint_group.hello1 : {
          group = v.id
        }
      ]
    })

    hello2 = merge(local.lb_be_config, {
      groups = [
        for v in google_compute_region_network_endpoint_group.hello1 : {
          group = v.id
        }
      ]
    })
  }
}

resource "google_compute_region_network_endpoint_group" "hello1" {
  for_each = google_cloud_run_service.hello1

  provider              = google-beta
  project               = var.project_id
  name                  = "hello1-${each.value.location}"
  network_endpoint_type = "SERVERLESS"
  region                = each.value.location

  cloud_run {
    service = google_cloud_run_service.hello1[each.key].name
  }
}

resource "google_compute_region_network_endpoint_group" "hello2" {
  for_each = google_cloud_run_service.hello2

  provider              = google-beta
  project               = var.project_id
  name                  = "hello2-${each.value.location}"
  network_endpoint_type = "SERVERLESS"
  region                = each.value.location

  cloud_run {
    service = google_cloud_run_service.hello2[each.key].name
  }
}

resource "google_compute_url_map" "hello" {
  name = "hello"

  default_route_action {
    fault_injection_policy {
      abort {
        http_status = 403
        percentage  = 100
      }
    }

    weighted_backend_services {
      backend_service = module.lb-http.backend_services["hello1"].id
    }
  }

  host_rule {
    hosts        = ["hello1.${replace(data.google_dns_managed_zone.default.dns_name, "/.$/", "")}"]
    path_matcher = "hello1"
  }

  path_matcher {
    name            = "hello1"
    default_service = module.lb-http.backend_services["hello1"].self_link
  }

  host_rule {
    hosts        = ["hello2.${replace(data.google_dns_managed_zone.default.dns_name, "/.$/", "")}"]
    path_matcher = "hello2"
  }

  path_matcher {
    name            = "hello2"
    default_service = module.lb-http.backend_services["hello2"].self_link
  }
}
