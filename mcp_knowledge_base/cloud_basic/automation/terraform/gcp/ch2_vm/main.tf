terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

variable "project" { type = string }
variable "region"  { type = string default = "asia-northeast3" }
variable "zone"    { type = string default = "asia-northeast3-a" }
variable "machine_type" { type = string default = "e2-micro" }

resource "google_compute_instance" "web" {
  name         = "web-01"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk { initialize_params { image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts" } }
  network_interface { network = "default" access_config {} }
  tags = ["http-server", var.env, var.project]
}

resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = "default"
  allow { protocol = "tcp" ports = ["80"] }
  target_tags = ["http-server"]
}

output "nat_ip" { value = google_compute_instance.web.network_interface[0].access_config[0].nat_ip }

variable "project" { type = string default = "cloud-basic" }
variable "department" { type = string default = "it" }
variable "env" { type = string default = "lab" }
variable "owner" { type = string default = "student" }
variable "cost_center" { type = string default = "training" }

