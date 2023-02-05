provider "aws"{ 
  region = "us-east-1"
  access_key = var.access.access
  secret_key = var.access.secret
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


 
resource "null_resource" "ansible" {
  provisioner "local-exec" {
  command = "ansible-playbook --private-key ubuntu.pem playbook.yml"
  }

  depends_on = [aws_instance.ubuntu]
}

#creating hosted zone
resource "aws_route53_zone" "route53" {
  name = "gerardokolie.me"
}

#creating route record7
resource "aws_route53_record" "record" {
  zone_id = aws_route53_zone.route53.id
  name = "www.gerardokolie.me"
  type = "AAAA"
  alias {
  name = aws_lb.load.dns_name
  zone_id = aws_lb.load.zone_id  
  evaluate_target_health = true
}
}


