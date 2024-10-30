provider "aws" {
  region = local.location

}

locals {
  instance_type = "t2.micro"
  location = "ap-southeast-1"
  env = "dev"
  vpc_cidr = "10.123.0.0/16"
}

module "networking" {
  source = "./modules/networking"
  vpc_cidr = local.vpc_cidr
  access_ip = var.access_ip
  private_sn_count = 2
  public_sn_cout = 2
  db_subnet_group = true
}

module "compute" {
  source = "./modules/compute"
  instance_type = local.instance_type
  ssh_key = "test"
  lb_tg_name = "three-tier-lb-tg"
  key_name = "test"
  public_subnets = module.networking.public_subnets
  private_subnets = module.networking.private_subnets
  frontend_app_sg = module.networking.frontend_app_sg
  bastion_sg = module.networking.bastion_sg
  backend_app_sg = module.networking.backend_app_sg
}

module "database" {
  source = "./modules/database"
  db_storage = 10
  db_instance_class = "db.t2.micro"
  db_engine_version = "8.0"
  db_name = "test"
  db_user = "test"
  db_passwrod = "pwd123"
  db_subnet_group_name = module.networking.rds_db_subnet_group[0]
  db_identifier = "ee-instance-demo"
  db_rds_sg = module.networking.rds_sg
  db_skip_snapshot = true
}

module "loadbalancing" {
  source = "./modules/loadbancing"
  lb_sg = module.networking.lb_sg
  public_subnets = module.networking.private_subnets
  app_sg = module.compute.app_frontend_asg
  lb_tg_port = 80
  lb_tg_protocol = "HTTP"
  vpc_id = module.networking.vpc_id
}

