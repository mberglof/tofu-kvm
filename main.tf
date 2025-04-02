terraform {
  required_version = ">= 1.11"
  # required_version = 1.8
  required_providers {
    libvirt = {
      source  = "registry.opentofu.org/dmacvicar/libvirt"
      version = "~> 0.8.3"
    }
    template = {
      source  = "registry.opentofu.org/hashicorp/template"
      version = "~> 2.2.0"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "volumes" {
  for_each = toset([for i in range(var.vm_count) : format("vm-%02d", i + 1)])
  name     = "${each.key}.${var.img_format}"
  pool     = "default"
  source   = var.img_source_alma
  format   = var.img_format
}

resource "libvirt_network" "tf_network" {
  name      = "tf-network"
  mode      = "nat"
  autostart = "true"
  addresses = [var.vm_network]
  dhcp {
    enabled = true
  }
  dns {
    enabled = true
  }
}

resource "libvirt_domain" "guest" {
  for_each = toset([for i in range(var.vm_count) : format("vm-%02d", i + 1)])
  name     = each.key
  memory   = var.mem_size
  vcpu     = var.cpu_cores

  disk {
    volume_id = libvirt_volume.volumes[each.key].id
  }

  # disk {
  #   file = "${path.module}/image.iso"
  # }

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name   = libvirt_network.tf_network.name
    wait_for_lease = true
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    autoport    = true
    listen_type = "address"
  }
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name      = "commoninit.iso"
  user_data = data.template_file.user_data.rendered
}

data "template_file" "user_data_yaml" {
  template = yamlencode({
    users = [
      {
        name          = "k8s_user"
        gecos         = "k8s_user"
        shell         = "/bin/bash"
        primary_group = "k8s"
        groups        = "users, adm"
        sudo          = "ALL=(ALL) NOPASSWD:ALL"
        lock_passwd   = false
        ssh_authorized_keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDX2gcunVOrLn5ULiht/FJo4xHjslWubSG7K5b5YFaF6",
        ]
      },
    ]
    package_update  = true
    package_upgrade = true
    packages = [
      "ca-certificates",
      "curl",
    ]
    runcmd = [
      "curl -LsSf https://get.k3s.io | sh -",
    ]
  })
}

data "template_file" "user_data" {
  template = file("${path.module}/${var.cloud_init}.cfg")
  vars = {
    ansible_git_repo = var.ansible_git_repo
    ansible_playbook = var.ansible_playbook
  }
}

output "node_info" {
  value = {
    for name, vm in libvirt_domain.guest : name => {
      name       = vm.name
      ip_address = vm.network_interface[0].addresses[0]
    }
  }
}
