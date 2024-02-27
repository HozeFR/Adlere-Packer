packer {
  required_version = ">= 1.7.7"
  required_plugins {
    vsphere = {
      source  = "github.com/hashicorp/vsphere"
      version = ">= v1.0.2"
    }
  }
}

variable "SSH_USER" {
  type    = string
  default = "lucas"
}

variable "SSH_PASSWORD" {
  type      = string
  default   = "password"
  sensitive = true
}

variable "PUB_KEY_PATH" {
  type    = string
  default = "~/.ssh/lb_key.pub"
}

variable "TEMPLATE_NAME" {
  type    = string
  default = "rhel8.4-lucas"
}

variable "TEMPLATE_VERSION" {
  type    = string
  default = "1.0.0"
}

variable "VCENTER_PACKER_PASSWORD" {
  type      = string
  default   = "${env("VCENTER_PACKER_PASSWORD")}"
  sensitive = true
}

variable "http_file" {
  type    = string
  default = "kickstart.cfg"
}

source "vsphere-iso" "lb-rhel" {

  vcenter_server      = "vcenter.ext.adlere.priv"
  username            = "cicd-proto3@adlere.priv"
  password            = "${var.VCENTER_PACKER_PASSWORD}"
  insecure_connection = true
  datacenter          = "Adlere"
  cluster             = "Adlere-WORKER"
  folder              = "Templates"
  datastore           = "vsanDatastore-WORKER"
  resource_pool       = "vDev"
  remove_cdrom        = true
  convert_to_template = true

  vm_name              = "${var.TEMPLATE_NAME}-${var.TEMPLATE_VERSION}"
  firmware             = "efi-secure"
  CPUs                 = 1
  cpu_cores            = 1
  RAM                  = 2048
  guest_os_type        = "rhel8_64Guest"
  cdrom_type           = "sata"
  disk_controller_type = ["pvscsi"]
  network_adapters {
    network      = "dVLAN_DEV_v10"
    network_card = "vmxnet3"
  }
  storage {
    disk_size             = 16384
    disk_thin_provisioned = true
  }

  iso_paths = ["[NAS3-Admin]_OS/RHEL/rhel-8.4-x86_64-dvd.iso"]

  ssh_password     = "${var.SSH_PASSWORD}"
  ssh_username     = "${var.SSH_USER}"
  ip_wait_timeout  = "90m"
  communicator     = "ssh"
  shutdown_command = "sudo shutdown -P now"

  http_directory = "http"
  http_port_min  = "8000"
  http_port_max  = "8050"
  boot_command = ["up", "wait", "e", "<down><down><end><wait>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "quiet text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${var.http_file}",
  "<enter><wait><leftCtrlOn>x<leftCtrlOff>"]
}

build {
  sources = ["source.vsphere-iso.lb-rhel"]

  provisioner "shell" {
    environment_vars = ["SSH_USER=${var.SSH_USER}",
    "PUB_KEY_PATH=${file(var.PUB_KEY_PATH)}"]
    scripts = ["./scripts/config.sh"]
  }

}
