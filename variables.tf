# variables.tf
#
# Variables are the "inputs" to your Terraform project. Each one has a
# description (shown in error messages and docs), a type, and usually a
# default. Values without a default MUST be supplied — typically via a
# terraform.tfvars file (copy terraform.tfvars.example to get started).

variable "aws_region" {
  description = "AWS region to create all resources in."
  type        = string
  default     = "us-east-1"
}

variable "ssh_allowed_cidr" {
  # NO default on purpose: you must consciously choose who can reach SSH.
  # Use YOUR public IP followed by /32 (a /32 means "exactly this one IP").
  # Find your IP at https://checkip.amazonaws.com — e.g. "203.0.113.25/32".
  description = "CIDR block allowed to SSH (port 22) into the EC2 instance. Use your home IP + /32, e.g. 203.0.113.25/32."
  type        = string

  validation {
    # cidrhost() fails on malformed CIDRs, so this catches typos like a
    # missing "/32" before Terraform ever talks to AWS.
    condition     = can(cidrhost(var.ssh_allowed_cidr, 0))
    error_message = "ssh_allowed_cidr must be valid CIDR notation, e.g. 203.0.113.25/32."
  }

  validation {
    # Guardrail: opening SSH to the whole internet is a classic beginner
    # mistake. If you truly want that (you don't), you'd have to edit this.
    condition     = var.ssh_allowed_cidr != "0.0.0.0/0"
    error_message = "Do not open SSH to 0.0.0.0/0 (the entire internet). Use your own IP with /32."
  }
}

variable "key_pair_name" {
  # Optional on purpose: the project works fine without SSH. If you want to
  # SSH in, create a key pair first (see README "Optional: SSH access") and
  # put its name here. null = launch the instance with no key pair.
  description = "Name of an EXISTING EC2 key pair for SSH access. Leave null to launch without SSH keys (you can still verify everything via the website URL)."
  type        = string
  default     = null
}

variable "instance_type" {
  description = "EC2 instance type. t3.micro is free-tier eligible for accounts on the current AWS Free Plan (t2.micro no longer is)."
  type        = string
  default     = "t3.micro"
}

variable "project_name" {
  description = "Short name used as a prefix for resource names and the S3 bucket."
  type        = string
  default     = "tf-learning"
}
