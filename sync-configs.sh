#!/usr/bin/env bash

# Pfade definieren
TF_VARS="terraform/terraform.tfvars"
GLOBALS="globals.yaml"

# Werte aus tfvars extrahieren
DOMAIN_RAW=$(grep "vm_name" $TF_VARS | cut -d'"' -f2 | cut -d'-' -f2-) # Extrahiert z.B. 'salad1n'
IP=$(grep "ip_address" $TF_VARS | cut -d'"' -f2)
GW=$(grep "gateway" $TF_VARS | cut -d'"' -f2)

# Globals.yaml neu schreiben
cat <<EOF > $GLOBALS
# EuroOpenCost-Lab: Auto-generated from terraform.tfvars
global:
  domain: "${DOMAIN_RAW}.dev"
  email: "admin@${DOMAIN_RAW}.dev"
  
network:
  gateway: "${GW}"
  master_ip: "${IP}"
  metallb_range: "192.168.10.50-192.168.10.60"
  traefik_lb_ip: "192.168.10.50"

proxmox:
  node: "$(grep "proxmox_node_name" $TF_VARS | cut -d'"' -f2)"
  bridge: "vnet1"

secrets:
  cloudflare_token: "PASTE_ME_MANUALLY"
  gitea_token: "PASTE_ME_MANUALLY"
EOF

echo "Success."