variable "proxmox_endpoint" {
  description = "The HTTP URL of the Proxmox API (e.g., https://192.168.1.100:8006/)"
  type        = string
}

variable "proxmox_api_token" {
  description = "The API Token ID and Secret for Proxmox authentication"
  type        = string
  sensitive   = true
}

variable "proxmox_insecure" {
  description = "Set to true to skip certificate verification for the Proxmox API"
  type        = bool
  default     = true
}

variable "proxmox_node_name" {
  description = "The name of the Proxmox node where VMs will be created"
  type        = string
}

variable "proxmox_node_address" {
  description = "The IP address or hostname of the Proxmox node for SSH access"
  type        = string
}

variable "proxmox_ssh_username" {
  description = "Username for the SSH connection to the Proxmox host"
  type        = string
  default     = "root"
}

variable "vm_name" {
  description = "The base hostname for the Kubernetes master node"
  type        = string
}

variable "vm_id" {
  description = "The starting VM ID for the master node (Workers will be offset by +10)"
  type        = number
}

variable "cpu" {
  description = "Number of CPU cores to allocate to each VM"
  type        = number
  default     = 2
}

variable "memory_mb" {
  description = "Amount of RAM in MB to allocate to each VM"
  type        = number
  default     = 4096
}

variable "disk_gb" {
  description = "Size of the root disk in GB for each VM"
  type        = number
  default     = 20
}

variable "ip_address" {
  description = "The static IPv4 address for the master node in CIDR notation (e.g., 192.168.1.10/24)"
  type        = string
}

variable "gateway" {
  description = "The default gateway for the VM network"
  type        = string
}

variable "ssh_pubkey" {
  description = "The public SSH key to be injected into the VM's authorized_keys"
  type        = string
}

variable "worker_nodes" {
  description = "A list of hostnames for the k3s worker nodes"
  type        = list(string)
  default     = []
}

variable "k3s_token" {
  default = "Test" # set your own token here
  sensitive = true
}