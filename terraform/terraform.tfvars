# Proxmox Connection
proxmox_endpoint     = "yourproxmoxserver:8006"
proxmox_api_token    = "your-proxmox-user@pve!terraform=your-api-token"
proxmox_node_name    = "homelab"
proxmox_node_address = "your-proxmox-node-ip"

# VM Configuration
vm_name    = "k3s-master-01"
vm_id      = 200                # Only Numbers without ""
cpu        = 2
memory_mb  = 4096
disk_gb    = 20

# Network & SSH
ip_address = "your-ip-address/24"
gateway    = "your-gateway-ip"
ssh_pubkey = "ssh-ed25519 AAAAC3Nza... your-key"

# Nodes
worker_nodes = ["k3s-worker-01", "k3s-worker-02"]

