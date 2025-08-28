terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.profile
}

variable "region" { type = string default = "ap-northeast-2" }
variable "profile" { type = string default = "default" }
variable "bucket_name" { type = string default = null }
variable "project" { type = string default = "cloud-basic" }
variable "department" { type = string default = "it" }
variable "env" { type = string default = "lab" }
variable "owner" { type = string default = "student" }
variable "cost_center" { type = string default = "training" }

locals {
  name = var.bucket_name != null ? var.bucket_name : "lab-static-${random_id.suffix.hex}"
}

resource "random_id" "suffix" { byte_length = 4 }

resource "aws_s3_bucket" "this" {
  bucket = local.name
  tags = {
    project     = var.project
    department  = var.department
    env         = var.env
    owner       = var.owner
    cost_center = var.cost_center
  }
}

resource "aws_s3_bucket_website_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  index_document { suffix = "index.html" }
  error_document { key = "404.html" }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "public" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]
    principals { type = "*" identifiers = ["*"] }
  }
}

resource "aws_s3_bucket_policy" "public" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.public.json
}

output "website_endpoint" { value = aws_s3_bucket_website_configuration.this.website_endpoint }

