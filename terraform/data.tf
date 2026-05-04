# 1. Vorhandene Datastores abfragen
data "proxmox_datastores" "all_storage" {
  node_name = "homelab" # name it after you node name
}

# 2. Netzwerke als Locals
locals {
  network_vnet1   = "vnet1" # name it after you networks
  network_vnet2   = "vnet2"
  network_default = "vmbr0"
}