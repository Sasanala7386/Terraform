terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~>5.0"
    }
  }
}

provider "aws" {
  region     = "ap-south-1"
  access_key = "AKIAU6GDY6Y3MWHQNX5E"
  secret_key = "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"
}

resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "demo-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "IGW"
  }
}

resource "aws_security_group" "sg" {
  name        = "first-SG"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.vpc.id

ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }
   
egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

 tags = {
    Name = "first-SG"
  }
}

resource "aws_route_table" "rt1" {
    vpc_id = aws_vpc.vpc.id
  
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
      name = "custom"
    }
  }
  
  resource "aws_route_table" "rt2" {
    vpc_id = aws_vpc.vpc.id
  
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway.ngw.id
    }
    tags = {
      name = "main"
    }
  }
  
  resource "aws_route_table_association" "as_1" {
    subnet_id      = aws_subnet.pub.id
    route_table_id = aws_route_table.rt1.id
  }
  
  resource "aws_route_table_association" "as_2" {
    subnet_id      = aws_subnet.pri.id
    route_table_id = aws_route_table.rt2.id
  }
  
  resource "aws_eip" "ip" {
    
  }
  
  resource "aws_nat_gateway" "ngw" {
    allocation_id = aws_eip.ip.id
    subnet_id     = aws_subnet.pri.id
  
    tags = {
      Name = "NGW"
    }
  }
  
  resource "aws_subnet" "pub" {
    vpc_id     = aws_vpc.vpc.id
    cidr_block = "10.0.1.0/24"
  
    tags = {
      Name = "pub"
    }
  }
  
  resource "aws_subnet" "pri" {
    vpc_id     = aws_vpc.vpc.id
    cidr_block = "10.0.3.0/24"
  
    tags = {
      Name = "pri"
    }
  }

  resource "aws_network_acl" "my_acl" {
    vpc_id = aws_vpc.vpc.id
  
    ingress {
      protocol   = -1
      rule_no    = 100
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 0
      to_port    = 0
    }
  
    egress {
      protocol   = -1
      rule_no    = 100
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 0
      to_port    = 0
    }
    
    tags = {
      Name = "NACL"
    }
  }

