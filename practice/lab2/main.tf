terraform {
  required_version = ">= 1.4.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }
}


provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_key_pair" "udemy-keypair" {
  key_name   = "udemy-keypair"
  public_key = file("./keypair/udemy-key.pub")
}

data "template_cloudinit_config" "config" {
  gzip          = false
  base64_encode = false

  #userdata
  part {
    content_type = "text/x-shellscript"
    content      = <<-EOF
      #!/bin/bash
      sudo yum update -y
      sudo yum install httpd -y
      sudo touch /var/www/html/index.html
      sudo chmod u+rwx,o+rxw  /var/www/html/index.html
      sudo echo "<h1>Welcome to Udemy</h1>" >> /var/www/html/index.html
      sudo echo "<h2>AWS Cloud for beginner. Please like, subscribe and share !!!!</h2>" >> /var/www/html/index.html
      sudo systemctl enable httpd 
      sudo service httpd start
      service httpd status
    EOF    
  }
}


resource "aws_instance" "demo-instance" {
  ami           = "ami-0dc44e17251b74325" # ami-0e4b5d31e60aa0acd
  instance_type = "t2.micro"
  key_name      = aws_key_pair.udemy-keypair.key_name
  tags = {
    Name = "Udemy Demo"
  }
  vpc_security_group_ids = [aws_security_group.test-security-group.id] # have many security_groups

  user_data = base64encode(data.template_cloudinit_config.config.rendered)

}

resource "aws_security_group" "test-security-group" {
  name        = "test-security-group"
  description = "test-security-group"

  ingress { // inbound
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress { //outbound
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

