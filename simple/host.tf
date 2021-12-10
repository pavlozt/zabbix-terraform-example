data "zabbix_template" "linux" {
  name = "Linux by Zabbix agent"
}

resource "zabbix_host" "vps" {
  host   = "testhost.local"
  name   = "my remote server"
  groups = [data.zabbix_hostgroup.linux_servers.id]
  interface {
    type = "agent"
    dns  = "testhost.local"
    ip   = "192.168.88.22"
  }
  templates = [data.zabbix_template.linux.id]
}


