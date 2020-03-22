variable "vpc_cidr" {
  description = "The CIDR block of the VPC"
}

variable "public_subnet_cidr" {
  description = "The CIDR block for the public subnet"
}

variable "private_subnet_cidr" {
  description = "The CIDR block for the private subnet"
}

variable "environment" {
  description = "The environment"
}

variable "region" {
  description = "The region to launch the bastion host"
}

variable "availability_zone" {
  description = "The az that the resources will be launched"
}

variable "bastion_ami" {
  default = {
    "eu-central-1" = "ami-0257508f40836e6cf"
    "eu-west-1" = "ami-01793b684af7a3e2c"
    "eu-west-2" = "ami-014ae7e330e2651dc"
    "eu-west-3" = "ami-0a3fd389b49c645bf"
  }
}

variable "key_name" {
  description = "The public key for the bastion host."
}