variable "project_id" {
  type = string
}

variable "name" {
  type = string
}

variable "oauth2_client_id" {
  type = string
}

variable "oauth2_client_secret" {
  type = string
}

variable "accessors" {
  type = list(string)
}

variable "enable_iap" {
  type    = bool
  default = true
}
