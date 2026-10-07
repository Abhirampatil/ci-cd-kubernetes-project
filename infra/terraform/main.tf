terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  type = string
}

variable "instance_id" {
  type = string
}

variable "desired_state" {
  type    = string
  default = "running"
  validation {
    condition     = contains(["running", "stopped"], var.desired_state)
    error_message = "desired_state must be 'running' or 'stopped'."
  }
}

# Starts or stops the EXISTING instance. It never creates or destroys it.
resource "aws_ec2_instance_state" "server" {
  instance_id = var.instance_id
  state       = var.desired_state
}

data "aws_instance" "server" {
  instance_id = var.instance_id
  depends_on  = [aws_ec2_instance_state.server]
}

output "state" {
  value = aws_ec2_instance_state.server.state
}

output "public_ip" {
  value = data.aws_instance.server.public_ip
}

output "jenkins_url" {
  value = data.aws_instance.server.public_ip != "" ? "http://${data.aws_instance.server.public_ip}:8080" : "(instance stopped)"
}

output "app_url" {
  value = data.aws_instance.server.public_ip != "" ? "http://${data.aws_instance.server.public_ip}:30080" : "(instance stopped)"
}