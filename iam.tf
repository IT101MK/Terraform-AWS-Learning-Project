# iam.tf
#
# IAM (Identity and Access Management) is how AWS controls "who can do what".
# Here we give the EC2 instance a ROLE — an identity it can assume — with a
# tightly scoped policy: it may read/write objects in OUR one S3 bucket and
# nothing else. This is called "least privilege" and it's the single most
# important IAM habit to build.

# The role itself. The "assume role policy" answers: WHO is allowed to wear
# this identity? Answer: the EC2 service (i.e., instances this role is
# attached to). Nothing here grants S3 access yet — that comes next.
resource "aws_iam_role" "web" {
  name = "${var.project_name}-web-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-web-role"
  }
}

# The permissions policy, attached inline to the role. Note how it names
# ONE specific bucket (by ARN), not "*" — the instance cannot touch any
# other bucket in the account.
#   - ListBucket applies to the bucket itself (arn:...:my-bucket)
#   - Get/PutObject apply to objects IN the bucket (arn:...:my-bucket/*)
# That bucket-vs-objects ARN distinction trips up everyone at first!
resource "aws_iam_role_policy" "s3_access" {
  name = "${var.project_name}-s3-access"
  role = aws_iam_role.web.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ListOurBucket"
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = aws_s3_bucket.data.arn
      },
      {
        Sid      = "ReadWriteObjectsInOurBucket"
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject"]
        Resource = "${aws_s3_bucket.data.arn}/*"
      }
    ]
  })
}

# An "instance profile" is the container that actually attaches a role to
# an EC2 instance (EC2 can't use a bare role directly — a historical AWS
# quirk). compute.tf references this profile by name.
resource "aws_iam_instance_profile" "web" {
  name = "${var.project_name}-web-profile"
  role = aws_iam_role.web.name

  tags = {
    Name = "${var.project_name}-web-profile"
  }
}
