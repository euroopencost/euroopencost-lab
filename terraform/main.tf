################################################################################
# 1. SNIPPETS (Cloud-Init Konfigurationen)
################################################################################

# Snippet for Master-Node (ID 990)
resource "proxmox_virtual_environment_file" "k3s_master_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "homelab"

  source_raw {
    data = <<EOF
#cloud-config
hostname: k3s-master-01
users:
  - name: ubuntu
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    # No password for console access, only SSH key auth
    passwd: ""
    lock_passwd: false
    ssh_authorized_keys:
      - ${trimspace(file("~/.ssh/id_ed25519.pub"))}

package_update: true
packages:
  - qemu-guest-agent
  - curl

runcmd:
  # K3s Installation
  - curl -sfL https://get.k3s.io | sh -s - server --token "${var.k3s_token}" --tls-san 192.168.10.2 --disable traefik
  # Kubeconfig Fixes
  - mkdir -p /home/ubuntu/.kube
  - cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config
  - chown ubuntu:ubuntu /home/ubuntu/.kube/config
  - echo "alias k='kubectl'" >> /home/ubuntu/.bashrc
EOF
    file_name = "k3s-master-config-new.yaml"
  }
}

# Snippets for the Worker-Nodes (ID 991, 992)
resource "proxmox_virtual_environment_file" "k3s_worker_config" {
  for_each     = toset(var.worker_nodes)
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "homelab"

  source_raw {
    data = <<EOF
#cloud-config
hostname: ${each.key}
users:
  - name: ubuntu
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    # No password for console access, only SSH key auth
    passwd: ""
    lock_passwd: false
    ssh_authorized_keys:
      - ${trimspace(file("~/.ssh/id_ed25519.pub"))}

runcmd:
  # Join to Master in VLAN 40
  - curl -sfL https://get.k3s.io | K3S_URL=https://192.168.10.2:6443 K3S_TOKEN="${var.k3s_token}" sh -
EOF
    file_name = "${each.key}-new.yaml"
  }
}

################################################################################
# 2. MASTER VM
################################################################################

resource "proxmox_virtual_environment_vm" "k3s_master" {
  name      = "k3s-master-990"
  node_name = "homelab"
  vm_id     = 990

  clone {
    vm_id = 9000
    full  = true
  }

  agent { enabled = false }
  cpu   { cores = 2 }
  memory { dedicated = 4096 }

  network_device {
    bridge = "vnet1" # Your SDN Interface for VLAN 40
  }

  disk {
    datastore_id = "local-lvm"
    size         = 20
    interface    = "scsi0"
  }

  initialization {
    user_data_file_id = proxmox_virtual_environment_file.k3s_master_config.id
    ip_config {
      ipv4 {
        address = "192.168.10.20/24"
        gateway = "192.168.10.1"
      }
    }
  }

  lifecycle {
    ignore_changes = [initialization, clone]
  }
}

################################################################################
# 3. WORKER MODULES
################################################################################

module "worker_01" {
  source          = "./modules/proxmox_vm"
  vm_name         = "k3s-worker-991"
  vm_id           = 991
  snippet_file_id = proxmox_virtual_environment_file.k3s_worker_config["k3s-worker-01"].id
  ip_address      = "192.168.10.21/24"
}

module "worker_02" {
  source          = "./modules/proxmox_vm"
  vm_name         = "k3s-worker-992"
  vm_id           = 992
  snippet_file_id = proxmox_virtual_environment_file.k3s_worker_config["k3s-worker-02"].id
  ip_address      = "192.168.10.22/24"
}