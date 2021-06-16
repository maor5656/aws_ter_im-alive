provider "aws" {
  profile = "default"
  region  = var.region_name
}

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
