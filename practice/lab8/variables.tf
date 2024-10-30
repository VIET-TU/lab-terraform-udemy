variable "region" {
  type = string
}

variable "workstation_ip" {
  type = string
}

variable "cidr_block" {
  type        = string
  description = "VPC cidr block. Example: 10.10.0.0/16"
}



variable "keypair_path" {
  type = string
}
variable "bastion_instance_type" {
  type = string
}
variable "bastion_ami" {
  type = string
}
variable "app_instance_type" {
  type = string
}
variable "app_ami" {
  type = string
}
variable "db_instance_type" {
  type = string
}
variable "db_ami" {
  type = string
}

variable "public_subnet_ips" {
  type = list(string)
  nullable = false
  
}
variable "private_subnet_ips" {
  type = list(string)
  nullable = false
}

variable "availability_zone_1" {
  type = string
}
variable "availability_zone_2" {
  type = string
}