# storage.tf
#
# A private S3 bucket the EC2 instance can read/write via its IAM role.
# S3 bucket names are GLOBALLY unique (across every AWS account on Earth),
# so we append a random suffix to avoid "bucket name already taken" errors.

# random_id generates 4 random bytes, shown as 8 hex characters
# (e.g. "a1b2c3d4"). The value is generated once at apply time and then
# saved in state, so it stays stable across future plans/applies.
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# The bucket itself. Buckets are private by default nowadays, but we make
# that explicit below with a public access block — belt and suspenders.
resource "aws_s3_bucket" "data" {
  bucket = "${var.project_name}-data-${random_id.bucket_suffix.hex}"

  # force_destroy lets "terraform destroy" delete the bucket even if it
  # still contains objects (like your SSH test file). Convenient for a
  # learning project; on real production buckets you'd usually omit this.
  force_destroy = true

  tags = {
    Name = "${var.project_name}-data"
  }
}

# Block ALL forms of public access to the bucket. With this in place, no
# bucket policy or ACL can accidentally make your data public.
resource "aws_s3_bucket_public_access_block" "data" {
  bucket = aws_s3_bucket.data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
