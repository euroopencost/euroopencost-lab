terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.102.0"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  insecure  = var.proxmox_insecure

  ssh {
    agent    = true
    username = var.proxmox_ssh_username
    node {
      name    = var.proxmox_node_name
      address = var.proxmox_node_address
    }
  }
}