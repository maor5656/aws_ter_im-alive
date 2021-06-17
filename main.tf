provider "aws" {
  profile = "default"
  region  = var.region_name
}

## Replace the data with local :
locals {
//  aws_ami =  Find the AMI you want in AWS account
  main_security_group = "General security group"

}

# Remove this section, organizations are not working like this.
data "aws_ami" "centos-last" {
  owners      = ["679593333241"]
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}
# --------------- Instance Configuration ---------------
resource "aws_instance" "centos" {
  ami                         = data.aws_ami.centos-last.id
  instance_type               = var.instance_type
  key_name                    = var.ssh_key_name
  user_data                   = file("./install-docker.sh")
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.subnet-uno.id
  security_groups             = [aws_security_group.ingress-all-im-alive.id]
  
  tags = {
    Name                      = var.instance_name
  }
}


# --------------- Network ---------------
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

resource "aws_internet_gateway" "im-alive-env-gw" {
  vpc_id = aws_vpc.im-alive.id

  tags = {
    Name = "im-alive-env-gw"
  }
}

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


# Get this section seperated, Read more about aws_security_group_rule and always add tags for naming convention
# --------------- Security groups ---------------
resource "aws_security_group" "ingress-all-im-alive" {
  name = "allow-all-sg-im-alive"
  vpc_id = aws_vpc.im-alive.id
  tags = {
    Name = local.main_security_group
  }
}
# Example:

# --------------- Security groups rules ---------------
resource "aws_security_group_rule" "allow-all-egress" {
  description = "Allow instance to access to world"
  from_port = 0
  protocol = "-1"
  security_group_id = aws_security_group.ingress-all-im-alive.id
  to_port = 0
  type = "egress"
}

resource "aws_security_group_rule" "allow-ssh-port-from-all" {
  description = "Allow SSH from anywhere"
  from_port = 22
  protocol = "-1"
  security_group_id = aws_security_group.ingress-all-im-alive.id
  to_port = 22
  type = "ingress"
}