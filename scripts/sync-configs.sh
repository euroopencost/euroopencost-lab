#!/usr/bin/env bash

# ==============================================================================
# EuroOpenCost-Lab: Configuration Sync Script
# Extracts variables from Terraform and populates globals.yaml dynamically
# ==============================================================================

# Determine the project root directory
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Define absolute paths
TF_VARS="$BASE_DIR/terraform/terraform.tfvars"
GLOBALS="$BASE_DIR/globals.yaml"

# Safety Check
if [ ! -f "$TF_VARS" ]; then
    echo "Error: $TF_VARS not found!"
    exit 1
fi

echo "Syncing configurations..."

# 1. Extract raw values
VM_NAME=$(grep "vm_name" "$TF_VARS" | cut -d'"' -f2)
RAW_IP=$(grep "ip_address" "$TF_VARS" | cut -d'"' -f2) # Result: e.g. 192.168.10.10/24
GW=$(grep "gateway" "$TF_VARS" | cut -d'"' -f2)
PVE_NODE=$(grep "proxmox_node_name" "$TF_VARS" | cut -d'"' -f2)

# 2. Clean Data
# Extract only the IP without CIDR (remove /24)
CLEAN_IP=$(echo $RAW_IP | cut -d'/' -f1)
# Extract the Subnet (e.g., 192.168.10)
SUBNET=$(echo $CLEAN_IP | cut -d'.' -f1-3)
# Extract Domain name from VM (e.g., euroopencost-salad1n -> salad1n)
DOMAIN_RAW=$(echo $VM_NAME | cut -d'-' -f2-)

# 3. Generate globals.yaml
cat <<EOF > "$GLOBALS"
# ==============================================================================
# EuroOpenCost-Lab: Auto-generated from terraform.tfvars
# WARNING: DO NOT COMMIT THIS FILE INTO ANY REPOSITORY
# ==============================================================================

global:
  domain: "${DOMAIN_RAW}.dev"
  email: "admin@${DOMAIN_RAW}.dev"
  
network:
  gateway: "${GW}"
  master_ip: "${RAW_IP}"
  # MetalLB range starts at .50 and ends at .60 of your master subnet
  metallb_range: "${SUBNET}.50-${SUBNET}.60"
  # Fixed LoadBalancer IP for Traefik Ingress
  traefik_lb_ip: "${SUBNET}.50"

proxmox:
  node: "${PVE_NODE}"
  bridge: "vnet1"

secrets:
  cloudflare_token: "PASTE_ME_MANUALLY"
  gitea_token: "PASTE_ME_MANUALLY"
EOF

echo "Success: $GLOBALS is ready."