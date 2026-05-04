# Terraform Deployment for euroopencost-lab

This directory contains the Terraform configuration for the euroopencost-lab. All production and sensitive values are managed via variables and must be provided in your own `.tfvars` file.

## Getting Started

1. **Install Terraform**
   - [Terraform Download](https://www.terraform.io/downloads.html)

2. **Set Variables**
   - Use a file named `terraform.tfvars` in the `terraform/` directory.
   - Add all required values there (see example below).

3. **Initialize & Deploy**
   ```sh
   terraform init
   terraform plan -var-file="terraform.tfvars"
   terraform apply -var-file="terraform.tfvars"
   ```

## Example `terraform.tfvars`

```
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

```

**Note:**
- Do not commit secrets, passwords, or production domains to the repository!
- All sensitive values must be managed in your `.tfvars` file.

## Structure
- `main.tf` – Main configuration
- `variables.tf` – All variable definitions
- `outputs.tf` – Outputs
- `terraform.tfvars` – Example for your own values
