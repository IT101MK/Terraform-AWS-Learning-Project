# outputs.tf
#
# Outputs are values Terraform prints after "terraform apply" — the useful
# facts about what it just built. You can re-print them anytime with
# "terraform output" (no changes are made by that command).

output "instance_public_ip" {
  description = "Public IP address of the EC2 web server."
  value       = aws_instance.web.public_ip
}

output "website_url" {
  description = "Open this in your browser to see the hello page."
  value       = "http://${aws_instance.web.public_ip}"
}

output "bucket_name" {
  description = "Name of the private S3 bucket the instance can read/write."
  value       = aws_s3_bucket.data.bucket
}

output "ssh_command" {
  description = "Example SSH command (only works if you set key_pair_name)."
  # If no key pair was configured, print a friendly hint instead of a
  # command that can't work. The ternary syntax is: condition ? yes : no
  value = var.key_pair_name != null ? "ssh -i ${var.key_pair_name}.pem ec2-user@${aws_instance.web.public_ip}" : "No key pair configured - set key_pair_name in terraform.tfvars to enable SSH (see README)."
}
