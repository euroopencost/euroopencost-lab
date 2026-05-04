output "vm_name" {
  description = "Der Name der erstellten VM"
  value       = proxmox_virtual_environment_vm.k3s_node.name
}

output "ip_address" {
  description = "Die zugewiesene IP-Adresse"
  value       = var.ip_address
}