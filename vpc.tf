# AWS VPC and Subnets : vpc.tf
resource "aws_vpc" "terraform_vpc" {
  cidr_block = "10.18.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "terraform vpc"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id = aws_vpc.terraform_vpc.id
  cidr_block = "10.18.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public subnet 1 terraform"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id = aws_vpc.terraform_vpc.id
  cidr_block = "10.18.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public subnet 2 terraform"
  }
}

resource "aws_internet_gateway" "terraform_igw" {
  vpc_id = aws_vpc.terraform_vpc.id

  tags = {
    Name = "terraform internet gateway"
  }
  
  lifecycle {
    create_before_destroy = true # contrôler l'ordre de création et de destruction des ressources
  }
}

resource "aws_route_table" "terraform_rt" {
  vpc_id = aws_vpc.terraform_vpc.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id     = aws_internet_gateway.terraform_igw.id
  }
  tags = {
    Name = "terraform route table"
  }
}

resource "aws_route_table_association" "public_subnet_1_association" {
    route_table_id      = aws_route_table.terraform_rt.id
    subnet_id           = aws_subnet.public_subnet_1.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
    route_table_id      = aws_route_table.terraform_rt.id
    subnet_id           = aws_subnet.public_subnet_2.id
}

resource "aws_security_group" "terraform_sg" {
  vpc_id        = aws_vpc.terraform_vpc.id
  description = "Terraform security group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}