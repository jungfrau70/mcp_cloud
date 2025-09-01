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
variable "user_name" { type = string default = "dev-user" }
variable "group_name" { type = string default = "DevTeam" }
variable "project" { type = string default = "cloud-basic" }
variable "department" { type = string default = "it" }
variable "env" { type = string default = "lab" }
variable "owner" { type = string default = "student" }
variable "cost_center" { type = string default = "training" }

resource "aws_iam_group" "dev" { name = var.group_name }

data "aws_iam_policy" "readonly" { arn = "arn:aws:iam::aws:policy/ReadOnlyAccess" }

resource "aws_iam_group_policy_attachment" "attach" {
  group      = aws_iam_group.dev.name
  policy_arn = data.aws_iam_policy.readonly.arn
}

resource "aws_iam_user" "user" {
  name = var.user_name
  tags = {
    project     = var.project
    department  = var.department
    env         = var.env
    owner       = var.owner
    cost_center = var.cost_center
  }
}

resource "aws_iam_user_group_membership" "m" {
  user = aws_iam_user.user.name
  groups = [
    aws_iam_group.dev.name
  ]
}

