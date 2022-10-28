data "google_dns_managed_zone" "default" {
  provider = google
  name     = var.name
}

resource "google_dns_record_set" "hello1" {
  provider     = google
  name         = "hello1.${data.google_dns_managed_zone.default.dns_name}"
  type         = "A"
  ttl          = 300
  managed_zone = data.google_dns_managed_zone.default.name
  rrdatas      = [module.lb-http.external_ip]
}

resource "google_dns_record_set" "hello2" {
  provider     = google
  name         = "hello2.${data.google_dns_managed_zone.default.dns_name}"
  type         = "A"
  ttl          = 300
  managed_zone = data.google_dns_managed_zone.default.name
  rrdatas      = [module.lb-http.external_ip]
}
