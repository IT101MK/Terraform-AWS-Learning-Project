# versions.tf
#
# This file tells Terraform which versions of Terraform itself and which
# "providers" (plugins that talk to cloud APIs) this project needs.
# Pinning versions makes your project reproducible: it will behave the same
# way next month as it does today, even if newer provider versions come out.

terraform {
  # Require a reasonably modern Terraform CLI, but stay below the next major
  # version so a future Terraform 2.0 doesn't silently break this project.
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    # The AWS provider is the plugin that knows how to create AWS resources
    # (VPCs, EC2 instances, S3 buckets, ...). "~> 5.70" means "any 5.x version
    # that is at least 5.70" — you get bug fixes but no surprise 6.0 upgrade.
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70"
    }

    # The random provider generates random values. We use it to add a unique
    # suffix to the S3 bucket name, because S3 bucket names must be globally
    # unique across ALL AWS accounts in the world.
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}
