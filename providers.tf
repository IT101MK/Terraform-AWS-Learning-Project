# Copyright (c) 2026 IT101MK (https://github.com/IT101MK)
# Licensed under the MIT License - see LICENSE.md.

# providers.tf
#
# Provider *configuration* lives here (as opposed to provider *versions*,
# which live in versions.tf). This is where we tell the AWS provider which
# region to create resources in and which tags to put on everything.

provider "aws" {
  # The region comes from a variable (see variables.tf) so you can change it
  # in one place. Credentials are NOT set here — the provider automatically
  # picks them up from the AWS CLI configuration ("aws configure") or
  # environment variables. Never hardcode credentials in .tf files!
  region = var.aws_region

  # default_tags are applied to every taggable resource automatically.
  # Tags are key/value labels — great for finding resources in the console
  # and for answering "what is this and can I delete it?" later.
  default_tags {
    tags = {
      Project   = "terraform-learning"
      ManagedBy = "terraform"
    }
  }
}
