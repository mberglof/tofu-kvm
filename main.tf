terraform {
  # required_version = "1.11.3"
  # required_version = 1.8
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.3"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "volumes" {
  name   = "tf-jammy.${var.img_format}"
  pool   = "default"
  source = var.img_source
  format = var.img_format
}

resource "libvirt_domain" "guest" {
  name   = "tf-jammy"
  memory = var.mem_size
  vcpu   = var.cpu_cores

  disk {
    volume_id = libvirt_volume.volumes.id
  }

  # disk {
  #   file = "${path.module}/image.iso"
  # }

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name   = "default"
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
}

output "user_data" {
  value = data.template_file.user_data_yaml
}
output "ips" {
  value = libvirt_domain.guest.*.network_interface.0.addresses
}
