terraform {
  required_providers {
    google = { source = "hashicorp/google" version = ">= 5.0" }
  }
}

provider "google" {
  project = var.project
}

variable "project" { type = string }
variable "member"  { type = string } # e.g. user:you@example.com
variable "role"    { type = string default = "roles/viewer" }

resource "google_project_iam_member" "binding" {
  project = var.project
  role    = var.role
  member  = var.member
}

