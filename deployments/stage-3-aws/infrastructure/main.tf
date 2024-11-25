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

resource "aws_vpc_security_group_ingress_rule" "allow_http_5000" {

  security_group_id = aws_security_group.java_app_sg.id
  from_port         = 5000
  ip_protocol       = "tcp"
  to_port           = 5000
  cidr_ipv4         = var.vpc_ssh_inbound_cidr
  tags = {
    Name = "Allow_9000"
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


  depends_on = [ aws_instance.java_db_instance ]
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
        GH_TOKEN = var.github_pat_token,
        DATABASE_IP = aws_instance.java_db_instance.private_ip
      }
    )
}



 # DATABASE
 
 
 # Security group
 resource "aws_security_group" "java_db_sg" {
     name = var.db_sg_name
   # Tags
   tags = {
     Name = var.db_sg_name
 
   }
 
 }
 
 # NSG Rules
 resource "aws_vpc_security_group_ingress_rule" "db_allow_ssh_22" {
 
   security_group_id = aws_security_group.java_db_sg.id
   from_port         = 22
   ip_protocol       = "tcp"
   to_port           = 22
   cidr_ipv4         = var.vpc_ssh_inbound_cidr
   tags = {
     Name = "Allow_SSH"
   }
 }
 
 resource "aws_vpc_security_group_ingress_rule" "allow_3306" {
 
   security_group_id = aws_security_group.java_db_sg.id
   from_port         = 3306
   ip_protocol       = "tcp"
   to_port           = 3306
   cidr_ipv4         = var.vpc_ssh_inbound_cidr
   tags = {
     Name = "Allow_3306"
   }
 }
 
 resource "aws_vpc_security_group_egress_rule" "db_allow_out_all" {
 
   security_group_id = aws_security_group.java_db_sg.id
   ip_protocol       = "All"
   cidr_ipv4         = var.vpc_ssh_inbound_cidr
   tags = {
     Name = "Allow_Out_all"
   }
 }
 
 
 # Resource to create
 resource "aws_instance" "java_db_instance" {
 
   # AMI ID ami-0c1c30571d2dae5c9 (for ubuntu 22.04 lts)
   ami = var.db_ami_id
 
   instance_type = var.db_instance_type
 
   # Public ip
   associate_public_ip_address = var.db_associate_pub_ip
 
   # Security group
   vpc_security_group_ids = [aws_security_group.java_db_sg.id]
 
   # SSH Key pair
   key_name = var.ssh_key_name
 
     user_data = templatefile("../provisioning/db-prov.sh",
      { 
        DATABASE_SEED_SQL = file("../provisioning/library.sql")
      }
    )
 
   # Name the resource
   tags = {
     Name = var.db_instance_name
   }
 
 }
 

