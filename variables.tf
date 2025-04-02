variable "cloud_init" {
  description = "Cloud init config file"
  default     = "cloud_init_alma"
  type        = string
}

variable "img_source" {
  description = "Ubuntu 22.04 LTS Cloud Image"
  default     = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  type        = string
}

variable "img_source_alma" {
  description = "Alma Linux 8 Cloud Image"
  default     = "AlmaLinux-8-GenericCloud-latest.x86_64.qcow2"
  type        = string
}

variable "img_format" {
  description = "QCow2 UEFI/GPT Bootable disk image"
  default     = "qcow2"
  type        = string
}

variable "mem_size" {
  description = "Amount of RAM (in MiB) for the virtual machine"
  type        = string
  default     = "2048"
}

variable "cpu_cores" {
  description = "Number of CPU cores for the virtual machine"
  type        = number
  default     = 2
}

variable "ansible_playbook" {
  description = "Name of playbook for cloud-init ansible module"
  default     = "bootvm.yaml"
  type        = string
}

variable "ansible_git_repo" {
  description = "URL for cloud-init ansible module"
  default     = "https://github.com/mberglof/tofu-kvm.git"
  type        = string
}

variable "vm_count" {
  description = "Number of virtual machines to create"
  type        = number
  default     = 1
}

variable "vm_network" {
  description = "Managed by terraform, for terraformed virtual machines"
  default     = "192.168.133.0/24"
  type        = string
}
