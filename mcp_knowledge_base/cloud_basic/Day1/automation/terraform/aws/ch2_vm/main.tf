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
variable "instance_type" { type = string default = "t2.micro" }
variable "ami_id" { type = string default = "ami-0e9bfdb247cc8de84" }

data "aws_vpc" "default" { default = true }
data "aws_subnet_ids" "default" { vpc_id = data.aws_vpc.default.id }

resource "aws_security_group" "web" {
  name        = "lab-web-sg"
  description = "Allow SSH/HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress { from_port = 22 to_port = 22 protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }
  ingress { from_port = 80 to_port = 80 protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }
  egress  { from_port = 0  to_port = 0  protocol = "-1"  cidr_blocks = ["0.0.0.0/0"] }
}

resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = element(data.aws_subnet_ids.default.ids, 0)
  vpc_security_group_ids = [aws_security_group.web.id]
  tags = {
    Name        = "lab-web-01"
    project     = var.project
    department  = var.department
    env         = var.env
    owner       = var.owner
    cost_center = var.cost_center
  }
}

output "public_ip" { value = aws_instance.web.public_ip }

variable "project" { type = string default = "cloud-basic" }
variable "department" { type = string default = "it" }
variable "env" { type = string default = "lab" }
variable "owner" { type = string default = "student" }
variable "cost_center" { type = string default = "training" }

