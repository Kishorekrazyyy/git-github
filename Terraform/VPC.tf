terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "myvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "VPC"
  }
}

resource "aws_subnet" "pubsub" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
  avalability_zone = "us-east-1a"

  tags = {
    Name = "PUBLIC SUBNET"
  }
}

resource "aws_subnet" "prisub" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
  avalability_zone = "us-east-1b"

  tags = {
    Name = "PRIVATE SUBNET"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "INTERNET GATE WAY"
  }
}

resource "aws_route_table" "pubrt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public route table"
  }
}

resource "aws_route_table_association" "pubrtass" {
  subnet_id      = aws_subnet.pubsub.id
  route_table_id = aws_route_table.pubrt.id
}


data "aws_eip" "by_allocation_id" {
  id = "eipalloc-12345678"
}


resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.eipalloc-12345678.id
  subnet_id     = aws_subnet.pubsub.id

  tags = {
    Name = "gw NAT"
  }
}

resource "aws_route_table" "prvrt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    Name = "Private route table"
  }
}

resource "aws_route_table_association" "prirtass" {
  subnet_id      = aws_subnet.prisub.id
  route_table_id = aws_route_table.prvrt.id
}

resource "aws_security_group" "pubsg" {
  name        = "pubsg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "PUBLIC SECURITY GROUP"
  }
}

resource "aws_security_group" "prisg" {
  name        = "prisg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["10.0.1.0/24"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "PRIVATE SECURITY GROUP"
  }
}

resource "aws_instance" "publicmachine" {
  ami                         =  "ami-0014ce3e52359afbd"
  instance_type               =  "t3.micro"  
  avalability_zone            =  "us-east-1a"
  subnet_id                   =  aws_subnet.pubsub.id
  key_name                    =  "project"
  vpc_security_group_ids      =  ["${aws_security_group.pubsg.id}"]
  associate_public_ip_address =  true
}
resource "aws_instance" "private" {
  ami                         =  "ami-0014ce3e52359afbd"
  instance_type               =  "t3.micro"
  avalability_zone            =  "us-east-1b"  
  subnet_id                   =  aws_subnet.prisub.id
  key_name                    =  "project"
  vpc_security_group_ids      =  ["${aws_security_group.prisg.id}"]
  associate_public_ip_address =  false
  
}
