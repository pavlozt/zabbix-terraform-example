data "zabbix_template" "cameras_http" {
  name = "Hikvision camera by HTTP"
}
data "zabbix_template" "icmp_ping" {
  name = "ICMP Ping"
}

data "local_file" "csvfile" {
  filename = "camera_data.csv"
}

locals {
  csv = csvdecode(data.local_file.csvfile.content)
}

resource "zabbix_host" "camera" {
  for_each = { for cam in local.csv : cam.id => cam }
  host     = each.value.hostname
  name     = each.value.hostname
  groups   = [zabbix_hostgroup.cameras.id]
  interface {
    type = "agent"
    ip   = each.value.ip
  }
  templates = lower(each.value.type) == "hik" ? [data.zabbix_template.cameras_http.id, data.zabbix_template.icmp_ping.id] : [ data.zabbix_template.icmp_ping.id] 
}


