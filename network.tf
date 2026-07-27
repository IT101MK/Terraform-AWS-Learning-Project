# network.tf
#
# Everything networking: the VPC (your private slice of AWS), a public
# subnet, an Internet Gateway, and the routing that connects them.
# Think of it like this:
#   VPC = your own private data center network
#   Subnet = one room in it
#   Internet Gateway = the front door to the internet
#   Route table = the signposts telling traffic how to get to that door

# The VPC: an isolated network with the private IP range 10.0.0.0/16
# (that's 65,536 addresses: 10.0.0.0 through 10.0.255.255).
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  # These enable AWS-provided DNS inside the VPC so the instance can
  # resolve hostnames (needed for package installs and talking to S3).
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# A "public" subnet: a 256-address chunk (10.0.1.0/24) of the VPC.
# It is public because (a) instances launched here get a public IP and
# (b) its route table sends internet traffic to the Internet Gateway.
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  # Give instances launched in this subnet a public IP automatically,
  # so we can reach the web server from a browser.
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

# The Internet Gateway (IGW): the VPC's door to the public internet.
# Without one, nothing in the VPC can reach or be reached from the internet.
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# A route table with one rule: "traffic to anywhere (0.0.0.0/0) goes out
# through the Internet Gateway". Local VPC traffic is routed automatically.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Attach the route table to our subnet. This association is what actually
# makes the subnet "public" — subnets don't have internet access until a
# route table with an IGW route is associated with them.
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# The Security Group: a virtual firewall attached to the EC2 instance.
# Rules are "allow" only — anything not allowed is blocked by default.
resource "aws_security_group" "web" {
  name        = "${var.project_name}-web-sg"
  description = "Allow HTTP from anywhere and SSH from my IP only"
  vpc_id      = aws_vpc.main.id

  # SSH (port 22) — ONLY from the CIDR you set in terraform.tfvars.
  # Restricting SSH to your own IP is a fundamental security habit.
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  # HTTP (port 80) — from anywhere, so you (and the world) can see the
  # nginx "hello" page in a browser.
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress = outbound traffic. Allow everything outbound so the instance
  # can download packages (nginx) and talk to the S3 API.
  # protocol "-1" means "all protocols".
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-web-sg"
  }
}
