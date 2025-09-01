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
variable "name"    { type = string default = null }

resource "random_id" "r" { byte_length = 4 }

locals { bucket = var.name != null ? var.name : "lab-static-${random_id.r.hex}" }

resource "google_storage_bucket" "b" {
  name     = local.bucket
  location = var.region
  website { main_page_suffix = "index.html" not_found_page = "404.html" }
  uniform_bucket_level_access = true
  labels = {
    project     = var.project
    department  = var.department
    env         = var.env
    owner       = var.owner
    cost_center = var.cost_center
  }
}

resource "google_storage_bucket_iam_member" "public" {
  bucket = google_storage_bucket.b.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

output "website_url" { value = "https://storage.googleapis.com/${google_storage_bucket.b.name}/index.html" }

variable "project" { type = string default = "cloud-basic" }
variable "department" { type = string default = "it" }
variable "env" { type = string default = "lab" }
variable "owner" { type = string default = "student" }
variable "cost_center" { type = string default = "training" }

