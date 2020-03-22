provider "aws" {
  profile = "default"
  region = "eu-central-1"
}
resource "aws_key_pair" "key" {
  key_name = var.key_name
  public_key = file("staging_key.pub")
}

