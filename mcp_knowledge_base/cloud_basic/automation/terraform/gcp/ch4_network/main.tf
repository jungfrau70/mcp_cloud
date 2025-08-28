terraform {
  required_providers {
    google = { source = "hashicorp/google" version = ">= 5.0" }
  }
}

provider "google" {
  project = var.project
  region  = var.region
}

variable "project" { type = string }
variable "region"  { type = string default = "asia-northeast3" }

resource "google_compute_network" "vpc" {
  name                    = "vpc-basic"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "public" {
  name          = "public-subnet"
  ip_cidr_range = "10.2.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
}

output "vpc" { value = google_compute_network.vpc.name }
output "public_subnet" { value = google_compute_subnetwork.public.name }

