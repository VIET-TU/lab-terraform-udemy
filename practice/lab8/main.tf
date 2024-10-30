terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

#==========Keypair===================
resource "aws_key_pair" "udemy-keypair" {
  key_name   = "keypair"
  public_key = file(var.keypair_path)
}
#====================================

module "network" {
  source = "./modules/network"
  region = var.region
  availability_zone_1 = var.availability_zone_1
  availability_zone_2 = var.availability_zone_2
  cidr_block = var.cidr_block
  public_subnet_ips = var.public_subnet_ips
  private_subnet_ips = var.private_subnet_ips
}

#====================================

module "security" {
  source = "./modules/security"

  vpc_id         = module.network.vpc_id
  workstation_ip = var.workstation_ip

  depends_on = [
    module.network
  ]
}

#====================================

module "bastion" {
  source = "./modules/bastion"

  instance_type = var.bastion_instance_type
  key_name      = aws_key_pair.udemy-keypair.key_name
  subnet_id     = module.network.public_subnet_ids[0]
  sg_id         = module.security.bastion_sg_id
  ami = var.bastion_ami
  depends_on = [
    module.network,
    module.security
  ]
}

#====================================

module "storage" {
  source = "./modules/storage"

  instance_type = var.db_instance_type
  key_name      = aws_key_pair.udemy-keypair.key_name
  subnet_id     = module.network.private_subnet_ids[0]
  sg_id         = module.security.mongodb_sg_id
  ami = var.db_ami
  depends_on = [
    module.network,
    module.security
  ]
}

#====================================

module "application" {
  source = "./modules/application"

  instance_type   = var.app_instance_type
  key_name      = aws_key_pair.udemy-keypair.key_name
  vpc_id          = module.network.vpc_id
  public_subnets  = module.network.public_subnet_ids
  private_subnets = module.network.private_subnet_ids
  webserver_sg_id = module.security.application_sg_id
  alb_sg_id       = module.security.alb_sg_id
  mongodb_ip      = module.storage.private_ip
  ami = var.app_ami
  depends_on = [
    module.network,
    module.security,
    module.storage
  ]
}

