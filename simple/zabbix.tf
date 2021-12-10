terraform {
  required_providers {
    zabbix = {
      source  = "tpretz/zabbix"
      version = "~> 0.15.0"
    }
  }
}


provider "zabbix" {
  username = var.zabbix_user
  password = var.zabbix_password
  url      = var.zabbix_url

  # Disable TLS verfication (false by default)
  tls_insecure = true

  # Serialize Zabbix API calls (false by default)
  # Note: race conditions have been observed, enable this if required
  serialize = true
}

variable "zabbix_url" {
  type = string
}
variable "zabbix_user" {
  type = string
}
variable "zabbix_password" {
  type = string
}
