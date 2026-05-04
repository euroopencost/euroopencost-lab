################################################################################
# DYNAMISCHE OUTPUTS
################################################################################

# Extrahiert die IPs direkt aus den VM-Ressourcen/Modulen
output "worker_ips" {
  value = {
    "k3s-master-01" = split("/", proxmox_virtual_environment_vm.k3s_master.initialization[0].ip_config[0].ipv4[0].address)[0]
    "k3s-worker-01" = split("/", module.worker_01.ip_address)[0] # Annahme: Dein Modul gibt ip_address zurück
    "k3s-worker-02" = split("/", module.worker_02.ip_address)[0]
  }
  description = "Die bereinigten IPv4 Adressen der Cluster-Nodes."
}

# Generiert fertige SSH-Kommandos inkl. Jump-Host Option (optional)
output "ssh_commands" {
  value = {
    master  = "ssh ubuntu@${split("/", proxmox_virtual_environment_vm.k3s_master.initialization[0].ip_config[0].ipv4[0].address)[0]}"
    worker1 = "ssh ubuntu@${split("/", module.worker_01.ip_address)[0]}"
    worker2 = "ssh ubuntu@${split("/", module.worker_02.ip_address)[0]}"
    
    # Der "Pro-Tipp" für dein Lab: SSH via Jump-Host (Proxmox-Node)
    # Falls du noch kein Routing konfiguriert hast, nutzt dieser Befehl Proxmox als Tunnel
    debug_master_via_jump = "ssh -J root@192.168.2.214 ubuntu@${split("/", proxmox_virtual_environment_vm.k3s_master.initialization[0].ip_config[0].ipv4[0].address)[0]}"
  }
}

output "mapped_networks" {
  value = {
    container = local.network_vnet1
    test      = local.network_vnet2
    default   = local.network_default
  }
}

output "proxmox_storage_full_debug" {
  value     = data.proxmox_datastores.all_storage
  sensitive = false # Falls du keine Secrets drin hast
}