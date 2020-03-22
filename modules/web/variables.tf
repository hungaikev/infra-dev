variable "web_instance_count" {
  description = "The total of web instances to run"
}

variable "region" {
  description = "The region to launch the instances"
}

variable "amis" {
  default = {
    "eu-central-1" = "ami-0257508f40836e6cf"
    "eu-west-1" = "ami-01793b684af7a3e2c"
    "eu-west-2" = "ami-014ae7e330e2651dc"
    "eu-west-3" = "ami-0a3fd389b49c645bf"
  }
}

variable "instance_type" {
  description = "The instance type to launch"
}

variable "private_subnet_id" {
  description = "The id of the private subnet to launch the instances"
}

variable "public_subnet_id" {
  description = "The id of the public subnet to launch the load balancer"
}

variable "vpc_cidr_block" {
  description = "The CIDR block from the VPC"
}

variable "key_name" {
  description = "The keypair to use on the instances"
}

variable "environment" {
  description = "The environment for the instance"
}

variable "vpc_id" {
  description = "The id of the vpc"
}