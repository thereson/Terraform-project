provider "aws"{ 
  region = "us-east-1"
  access_key = "AKIAZ4WPQRJB2UNGAZM6"
  secret_key = "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"
}

#creating vpc
resource "aws_vpc" "net" {
 cidr_block = var.alt
 enable_dns_hostnames = true 
 tags = {
    Name = "net"
  }
}

#creating  subnets in Vpc
resource "aws_subnet" "cloud" {
  for_each = var.subnet
  vpc_id     = aws_vpc.net.id
  cidr_block = each.value["block"]
  availability_zone = each.value["az"] 
}
  
#creating internet gateway
resource "aws_internet_gateway" "net-gw" {
  vpc_id = aws_vpc.net.id

  tags = {
    Name = "net-gw"
  }
}

#creating route tables
resource "aws_route_table" "net-route" {
  vpc_id = aws_vpc.net.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.net-gw.id
  }
  tags = {
    Name = "net-route"
  }
}

#creating route association for subnet 
resource "aws_route_table_association" "time" {
  for_each = aws_subnet.cloud
  subnet_id      = each.value.id
  route_table_id = aws_route_table.net-route.id
}
#resource
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}
  
#creating resoutce2
resource "aws_key_pair" "deployer" {
  key_name   = "kali"
  public_key = tls_private_key.ssh.public_key_openssh
}
#resource3
resource "local_file" "key" {
  content = tls_private_key.ssh.private_key_pem
  filename = "kali.pem"
  file_permission = "400" 
}

#creating public EC2 instance
resource "aws_instance" "pub" {
  for_each = aws_subnet.cloud
  ami              = "ami-00874d747dde814fa"
  subnet_id        = each.value.id
  instance_type    = "t2.micro"
  key_name         = "kali"
  security_groups  = [aws_security_group.allow.id]
  associate_public_ip_address = true
  
  provisioner "local-exec" {
  command = "echo ${self.public_ip} >> ./host-inventory"
  } 

} 
resource "null_resource" "ansible" {
  provisioner "local-exec" {
  command = "ansible-playbook --private-key kali.pem play.yml"
  }

  depends_on = [aws_instance.pub]
}

#creating hosted zone
resource "aws_route53_zone" "route53" {
  name = "cindychinma123.me"
}

#creating route record
resource "aws_route53_record" "record" {
  zone_id = aws_route53_zone.route53.id
  name = "www.cindychinma123.com"
  type = "A"
  alias {
  name = aws_lb.load.dns_name
  zone_id = aws_lb.load.zone_id  
  evaluate_target_health = true
}
}


