resource "proxmox_virtual_environment_vm" "k3s_node" {
  name        = var.vm_name
  node_name   = var.target_node
  description = "Managed by Terraform - ${var.node_name}"
  tags        = ["terraform", var.node_name]
  vm_id       = var.vm_id

  clone {
    vm_id = 9000
    full  = true
  }

  # Das verhindert, dass Terraform ewig wartet, wenn der Agent 
  # beim Booten noch nicht bereit ist.
  agent { 
    enabled = false
  }

  cpu { cores = 2 }
  memory { dedicated = 2048 }

  network_device { bridge = "vnet1" }

  # Falls dein Template nur 2GB hat, vergrößere es hier direkt:
  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 20
  }

  initialization {
    user_data_file_id = var.snippet_file_id
    ip_config {
      ipv4 {
        address = var.ip_address
        # Gateway hinzufügen, falls die Worker ins Internet müssen (für k3s install)
        gateway = "192.168.10.1" 
      }
    }
  }
}