# compute.tf
#
# The EC2 instance (a virtual server) and the lookup for which machine
# image (AMI) it should run.

# A "data source" READS existing information from AWS instead of creating
# anything. Here we ask AWS: "what is the newest official Amazon Linux 2023
# AMI for x86_64?" — so we never hardcode an AMI ID that goes stale.
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"] # Only official Amazon-published images.

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# The EC2 instance itself: a t3.micro (free-tier eligible) running the AMI
# found above, placed in our public subnet, protected by our security group,
# and wearing the IAM instance profile from iam.tf (its "ID badge" for S3).
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type

  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]

  # The instance profile links the IAM role (iam.tf) to this instance,
  # letting software on the instance call S3 WITHOUT any stored passwords
  # or access keys. This is the secure, recommended pattern.
  iam_instance_profile = aws_iam_instance_profile.web.name

  # Optional SSH key pair. If var.key_pair_name is null (the default),
  # the instance launches with no key — you can still use the website.
  key_name = var.key_pair_name

  # user_data is a script that runs ONCE, on first boot, as root.
  # We use it to install nginx and drop in a hello page. templatefile()
  # reads user_data.sh.tpl and fills in the ${bucket_name} placeholder.
  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    bucket_name = aws_s3_bucket.data.bucket
  })

  tags = {
    Name = "${var.project_name}-web"
  }
}
