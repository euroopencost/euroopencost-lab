variable "vm_name" {
  description = "Name der virtuellen Maschine"
  type        = string
}

variable "vm_id" {
  description = "Die eindeutige VM ID in Proxmox"
  type        = number
}

variable "target_node" {
  description = "Der physikalische Proxmox Node"
  type        = string
  default     = "homelab" # Hier dein Standard-Node
}

variable "node_name" {
  description = "Anzeigename oder Tag für den Node"
  type        = string
  default     = "default lab" # Dein gewünschter Default-Wert
}

variable "snippet_file_id" {
  description = "ID des Cloud-Init Snippets"
  type        = string
}

variable "ip_address" {
  description = "Statische IP mit Subnetzmaske (z.B. 192.168.10.11/24) oder 'dhcp'"
  type        = string
  default     = "dhcp"
}