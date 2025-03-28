variable "cloud_init" {
  description = "Cloud init config file"
  default     = "cloud_init"
  type        = string
}

variable "img_source" {
  description = "Ubuntu 22.04 LTS Cloud Image"
  default     = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
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
