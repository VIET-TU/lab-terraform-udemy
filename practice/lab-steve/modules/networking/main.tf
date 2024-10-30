resource "aws_vpc" "three_tier_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "three_tier_vpc"
  }
}

data "aws_availability_zones" "availabe" {
  
}

resource "aws_internet_gateway" "three_tier_internet_getway" {
  vpc_id = aws_vpc.three_tier_vpc.id
  tags = {
    Name = "three_tier_ig"
  }
}
resource "aws_subnet" "three_tier_public_subnets" {
  vpc_id = aws_vpc.three_tier_vpc.id
  count = var.public_sn_cout
  cidr_block = "10.123.${10 + count.index}.0/24"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.availabe.names[count.index]
  tags = {
    Name = "three_tier_public_subnet_${count.index + 1}"
  }
}

resource "aws_route_table" "three_tier_public_rt" {
  vpc_id = aws_vpc.three_tier_vpc.id
  tags = {
    Name = "three_tier_public_rt"
  }
}

resource "aws_route_table_association" "three_tier_public_associate" {
  route_table_id = aws_route.public_subnets_rt.id
  count = var.public_sn_cout
  subnet_id = aws_subnet.three_tier_public_subnets[count.index].id
}

resource "aws_route" "public_subnets_rt" {
  route_table_id = aws_route_table.three_tier_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.three_tier_internet_getway.id
}

resource "aws_eip" "three_tier_ngw" {
    domain = "vpc"

}

resource "aws_nat_gateway" "three_tier_vpc" {
   count = var.public_sn_cout
  subnet_id = aws_subnet.three_tier_public_subnets[count.index].id
  allocation_id = aws_eip.three_tier_ngw.id
}

resource "aws_subnet" "three_tier_private_subnets" {
  vpc_id = aws_vpc.three_tier_vpc.id
  count = var.private_sn_count
  cidr_block = "10.123.${20 + count.index}.0/24"
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.availabe.names[count.index]
  tags = {
    Name = "three_tier_private_subnet_${count.index + 1}"
  }
}
resource "aws_route_table" "three_tier_private_rt" {
  vpc_id = aws_vpc.three_tier_vpc.id
  tags = {
    Name = "three_tier_private_rt"
  }
}

resource "aws_route_table_association" "three_tier_private_associate" {
  route_table_id = aws_route_table.three_tier_private_rt.id
  count = var.public_sn_cout
  subnet_id = aws_subnet.three_tier_private_subnets[count.index].id
}

resource "aws_subnet" "three_tier_private_db" {
  vpc_id = aws_vpc.three_tier_vpc.id
  count = var.private_sn_count
  cidr_block = "10.123.${40 + count.index}.0/24"
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.availabe.names[count.index]
  tags = {
    Name = "three_tier_private_db_subnet_${count.index + 1}"
  }
}


#SG for bastion host
resource "aws_security_group" "three_tier_bastion_sg" {
  name = "three_tier_sg_bastion"
  vpc_id = aws_vpc.three_tier_vpc.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = var.access_ip
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#SG for lb
resource "aws_security_group" "three_tier_lb_sg" {
  name = "three_tier_sg_lb"
  vpc_id = aws_vpc.three_tier_vpc.id
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = ["0.0.0.0/0"]

  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

locals {
  port_in_80 = [80]
  port_in_22 = [22]
  port_in_3306 = [3306]
}


#SG for frontend


resource "aws_security_group" "three_tier_frontend_sg" {
  name = "three_tier_sg_fe"
  vpc_id = aws_vpc.three_tier_vpc.id

dynamic "ingress" {
  for_each = toset(local.port_in_22)
  content {
    from_port = ingress.value
    to_port = ingress.value
    protocol = "tcp"
     security_groups = [aws_security_group.three_tier_bastion_sg.id]
  }
}

dynamic "ingress" {
  for_each = toset(local.port_in_80)
  content {
    from_port = ingress.value
    to_port = ingress.value
    protocol = "tcp"
     security_groups = [aws_security_group.three_tier_lb_sg.id]
  }
}

 egress  {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}



#SG for backend


resource "aws_security_group" "three_tier_backend_sg" {
  name = "three_tier_sg_be"
  vpc_id = aws_vpc.three_tier_vpc.id

dynamic "ingress" {
  for_each = toset(local.port_in_22)
  content {
    from_port = ingress.value
    to_port = ingress.value
    protocol = "tcp"
     security_groups = [aws_security_group.three_tier_bastion_sg.id]
  }
}

dynamic "ingress" {
  for_each = toset(local.port_in_80)
  content {
    from_port = ingress.value
    to_port = ingress.value
    protocol = "tcp"
     security_groups = [aws_security_group.three_tier_frontend_sg.id]
  }
}

 egress  {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#SG for db


resource "aws_security_group" "three_tier_db_sg" {
  name = "three_tier_sg_db"
  vpc_id = aws_vpc.three_tier_vpc.id

dynamic "ingress" {
  for_each = toset(local.port_in_3306)
  content {
    from_port = ingress.value
    to_port = ingress.value
    protocol = "tcp"
     security_groups = [aws_security_group.three_tier_backend_sg.id]
  }
}


 egress  {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "three_tier_db_subnet_group" {
  count = var.db_subnet_group == true ? 1 : 0
  name = "db_subgroup"
  subnet_ids = [aws_subnet.three_tier_private_db[0].id,aws_subnet.three_tier_private_db[1].id ]
    tags = {
      Name = "subnet_group_db"
    }
}
