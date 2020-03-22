/* Security group for the web */
resource "aws_security_group" "web_server_sg" {
  name = "${var.environment}-web-server-sg"
  description = "Security group for the web that allows web traffic from the internet"
  vpc_id = var.vpc_id

  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = [var.vpc_cidr_block]
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
  tags  = {
    Name = "${var.environment}-web-server-sg"
    Environment = var.environment
    Tool = "Terraform"
  }
}

resource "aws_security_group" "web_inbound_sg" {
  name = "${var.environment}-web-inbound-sg"
  description = "Allow HTTP from anywhere"
  vpc_id = var.vpc_id

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8
    protocol = "icmp"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-web-inbound-sg"
    Environment = var.environment
    Tool = "Terraform"
  }
}

/* Web servers */
resource "aws_instance" "web" {
  ami = lookup(var.amis, var.region)
  instance_type = var.instance_type
  count = var.web_instance_count
  subnet_id = var.private_subnet_id
  vpc_security_group_ids = [aws_security_group.web_inbound_sg.id]
  key_name = var.key_name
  user_data = file("${path.module}/files/user_data.sh")

  tags = {
    Name = "${var.environment}-web-${count.index+1}"
    Environment = var.environment
    Tool = "Terraform"
  }
}

/* Load Balancer */
resource "aws_elb" "web" {
  name = "${var.environment}-web-lb"
  subnets = [var.public_subnet_id]
  security_groups = [aws_security_group.web_inbound_sg.id]

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
  instances = aws_instance.web.*.id

  tags = {
    Environment = var.environment
    Tool = "Terraform"
  }
}































