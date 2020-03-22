resource "aws_vpc" "main-vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "${var.environment}-vpc"
    Environment = var.environment
    Tool = "Terraform"
  }
}

/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "${var.environment}-igw"
    Environment = var.environment
    Tool = "Terraform"
  }
}

/* Elastic IP for NAT */
resource "aws_eip" "nat_eip" {
  vpc = true
}

/* NAT */
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.public_subnet.id
}

/* Public subnet */
resource "aws_subnet" "public_subnet" {
  cidr_block = var.public_subnet_cidr
  vpc_id = aws_vpc.main-vpc.id
  availability_zone = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-public-subnet"
    Environment = var.environment
    Tool = "Terraform"
  }
}

/* Private subnet */
resource "aws_subnet" "private_subnet" {
  cidr_block = var.private_subnet_cidr
  vpc_id = aws_vpc.main-vpc.id
  map_public_ip_on_launch = false
  availability_zone = var.availability_zone

  tags = {
    Name = "${var.environment}-private-subnet"
    Environment = var.environment
    Tool = "Terraform"
  }
}

/* Routing table for private subnet */
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "${var.environment}-private-route-table"
    Environment = var.environment
    Tool = "Terraform"
  }
}

/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "${var.environment}-public-route-table"
    Environment = var.environment
    Tool = "Terraform"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.ig.id
}

resource "aws_route" "private_nat_gateway" {
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

/* Rout table assciations */
resource "aws_route_table_association" "public" {
  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.public_subnet.id
}

resource "aws_route_table_association" "private" {
  route_table_id = aws_route_table.private.id
  subnet_id = aws_subnet.private_subnet.id
}


/* Default security group */
resource "aws_security_group" "default" {
  name = "${var.environment}-default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id = aws_vpc.main-vpc.id

  ingress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    self = true
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    self = true
  }

  tags = {
    Name = "${var.environment}-default-sg"
    Environment = var.environment
    Tool = "Terraform"
  }
}

resource "aws_security_group" "bastion" {
  vpc_id = aws_vpc.main-vpc.id
  name = "${var.environment}-bastion-host"
  description = "Allow SSH to bastion host"

  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8
    protocol = "icmp"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-bastin-sg"
    Environment = var.environment
    Tool = "Terraform"
  }
}

resource "aws_instance" "bastion" {
  ami = lookup(var.bastion_ami, var.region)
  instance_type = "t2.micro"
  key_name = var.key_name
  monitoring = true
  vpc_security_group_ids = [aws_security_group.bastion.id]
  subnet_id = aws_subnet.public_subnet.id
  associate_public_ip_address = true

  tags = {
    Name = "${var.environment}-bastion"
    Environment = var.environment
    Tool = "Terraform"
  }
}