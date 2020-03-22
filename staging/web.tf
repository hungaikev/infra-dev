module "web" {
  source = "../modules/web"
  web_instance_count = var.web_instance_count
  environment = var.environment
  instance_type = "t2.micro"
  key_name = var.key_name
  private_subnet_id = module.networking.private_subnet_id
  public_subnet_id = module.networking.public_subnet_id
  region = var.region
  vpc_cidr_block = var.vpc_cidr
  vpc_id = module.networking.vpc_id
}
