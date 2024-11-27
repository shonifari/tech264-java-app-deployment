# Create an EC2 instance

# Provider
provider "aws" {

  # Which region we use
  region = "eu-west-1"
}



# APPLICATION


# Security group
resource "aws_security_group" "java_app_sg" {
    name = var.app_sg_name
  # Tags
  tags = {
    Name = var.app_sg_name

  }

}

# NSG Rules
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_22" {

  security_group_id = aws_security_group.java_app_sg.id
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  cidr_ipv4         = var.vpc_ssh_inbound_cidr
  tags = {
    Name = "Allow_SSH"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {

  security_group_id = aws_security_group.java_app_sg.id
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
  cidr_ipv4         = var.vpc_ssh_inbound_cidr
  tags = {
    Name = "Allow HTTP"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_out_all" {

  security_group_id = aws_security_group.java_app_sg.id
  ip_protocol       = "All"
  cidr_ipv4         = var.vpc_ssh_inbound_cidr
  tags = {
    Name = "Allow_Out_all"
  }
}


# Resource to create
resource "aws_instance" "java_app_instance" {

  # AMI ID ami-0c1c30571d2dae5c9 (for ubuntu 22.04 lts)
  ami = var.app_ami_id

  instance_type = var.app_instance_type

  # Public ip
  associate_public_ip_address = var.app_associate_pub_ip

  # Security group
  vpc_security_group_ids = [aws_security_group.java_app_sg.id]

  # SSH Key pair
  key_name = var.ssh_key_name
 
  
  # Name the resource
  tags = {
    Name = var.app_instance_name
  }

  user_data = templatefile("../provisioning/java-app-prov.sh",
      { 
        DOCKER_COMPOSE_YML = file("../provisioning/docker-compose.yml") ,
        DATABASE_SEED_SQL = file("../provisioning/library.sql") 
        
      }
    )
}


