# Manage Zabbix with Terraform. Example configuration. #

  Excel🔢  + Zabbix📈 + Terraform🌎🔨 = ❤️ 


At first you need basic Terraform knowledge.  If not, consider using [Hashicorp tutorials](https://learn.hashicorp.com/terraform).

Let's use [Thomas Pressnell Terraform provider](https://registry.terraform.io/providers/tpretz/zabbix/latest) with most reachest features.

## Create  zabbix  api user ##
 Go to Administration/Users/Create user **"apiuser"**. Add to Super Administrators. Set proper password. No need configure media for this user.

# Basic example # 
First you need declare provider :
```
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
  url = var.zabbix_url
  # Disable TLS verfication (false by default)
  tls_insecure = true
  # Serialize Zabbix API calls (false by default)
  # Note: race conditions have been observed, enable this if required
  serialize = true
}
```
Define some variables:
```
variable "zabbix_url"  {
  type = string
}
variable "zabbix_user"  {
  type = string
}
variable "zabbix_password" {
  type = string
}
```
Then need to use standard zabbix  template "Linux by Zabbix agent". You should use exactly template names in this section.

 ```
 data "zabbix_template" "linux" {
  name = "Linux by Zabbix agent"
}
```
 and host definition :
```
resource "zabbix_host" "vps" {
  host = "testhost.local"
  name = "my remote server"
  groups = [ data.zabbix_hostgroup.linux_servers.id ]
  interface {
    type = "agent"
    dns = "testhost.local"
    ip = "192.168.88.22"
  }
  templates = [data.zabbix_template.linux.id]
}
```

Now you can sequentially  run **terraform init,  terraform plan, terraform apply** commands.

 Full example in directory [simple/](simple/)

# Bunch of IP cameras example # 
 We will use "Hikvision camera by HTTP" and "ICMP ping" standard templates.
## Prepare CSV
 I suppose you know wwwwhow to convert an excel to csv - a machine-friendly form of data.
 You need a unique id for a camera with Terraform like to operate. In this case, if you swap or reorder rows in an excel file, terraform does not re-create corresponding records.
 I don't use password in this example. You can define user and password globally in Hikvision template.
```
id,hostname,ip,comment
1,cam-1.local,192.168.88.201,Camera 1
2,cam-2.local,192.168.88.202,Camera 2
3,cam-3.local,192.168.88.202,Camera 3
```

## Parsing csv ## 
 We will use function [csvdecode](https://www.terraform.io/docs/language/functions/csvdecode.html) which properly declarative designed.
```
data "local_file" "csvfile" {
  filename = "camera_data.csv"
}
locals {
  csv = csvdecode(data.local_file.csvfile.content)
}
```
To declare cameras you should use **for_each** statement:
```
resource "zabbix_host" "camera" {
  for_each = { for cam in local.csv : cam.id => cam }
  host     = each.value.hostname
  name     = each.value.hostname
  groups   = [data.zabbix_hostgroup.cameras.id]
  interface {
    type = "agent"
    ip   = each.value.ip
  }
  templates = [data.zabbix_template.cameras_http.id,
   data.zabbix_template.icmp_ping.id]
}
```


## Combine all together ##
Full example in directory [multiple\_cameras/](multiple\_cameras)

