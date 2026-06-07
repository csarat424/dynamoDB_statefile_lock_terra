#provider block
provider "aws" {
  region = var.region_name
}

#s3 backend block
terraform {
  backend "s3" {
    bucket = "csarat424"
    key    = "versioning.tfstate"
    region = "us-east-1"
  }
}

#VPC Block
resource "aws_vpc" "VPC_Terra" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_tag
  }
}

#subnet Block
resource "aws_subnet" "Pub_Subnet_Terra" {
  vpc_id            = aws_vpc.VPC_Terra.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.subnet_az

  tags = {
    Name = var.subnet_tag
  }
}

#Internet Gateway Block 
resource "aws_internet_gateway" "Igw_Terra" {
  vpc_id = aws_vpc.VPC_Terra.id

  tags = {
    Name = var.igw_tag
  }
}

#Route Table Block 
resource "aws_route_table" "RT_Terra" {
  vpc_id = aws_vpc.VPC_Terra.id

  route {
    cidr_block = var.rt_cidr_block
    gateway_id = aws_internet_gateway.Igw_Terra.id
  }

  tags = {
    Name = var.rt_tag
  }
}

#Route Table Association Block
resource "aws_route_table_association" "RTA_Terra" {
  subnet_id      = aws_subnet.Pub_Subnet_Terra.id
  route_table_id = aws_route_table.RT_Terra.id
}

#Security Groups 
resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.VPC_Terra.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# resource "aws_instance" "web-1" {
#   ami                         = var.ami
#   availability_zone           = var.ec2_az
#   instance_type               = var.ec2_type
#   key_name                    = var.key_pair
#   subnet_id                   = aws_subnet.Pub_Subnet_Terra.id
#   vpc_security_group_ids      = ["${aws_security_group.allow_all.id}"]
#   associate_public_ip_address = true
#   tags = {
#     Name       = "Server-1"
#     Env        = "Prod"
#     Owner      = "Sarat"
#     CostCenter = "ABCD"
#   }
# }
