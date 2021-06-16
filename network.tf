//network.tf
resource "aws_vpc" "im-alive" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "im-alive-vpc"
  }
}

resource "aws_eip" "ip-im-alive-env" {
  instance = aws_instance.centos.id
  vpc      = true
}

//subnets.tf
resource "aws_subnet" "subnet-uno" {
  cidr_block = cidrsubnet(aws_vpc.im-alive.cidr_block, 3, 1)
  vpc_id = aws_vpc.im-alive.id
  availability_zone = "us-east-2a"
}

resource "aws_route_table" "route-table-im-alive-env" {
  vpc_id = aws_vpc.im-alive.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.im-alive-env-gw.id
  }

  tags = {
    Name = "im-alive-env-route-table"
  }

}

resource "aws_route_table_association" "subnet-association" {
  subnet_id      = aws_subnet.subnet-uno.id
  route_table_id = aws_route_table.route-table-im-alive-env.id
}

//security.tf
resource "aws_security_group" "ingress-all-im-alive" {
name = "allow-all-sg-im-alive"
vpc_id = aws_vpc.im-alive.id
ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
from_port = 22
    to_port = 22
    protocol = "tcp"
  }

// Terraform removes the default rule
  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
  }
}

//gateways.tf
resource "aws_internet_gateway" "im-alive-env-gw" {
  vpc_id = aws_vpc.im-alive.id
 
tags = {
    Name = "im-alive-env-gw"
  }
}

