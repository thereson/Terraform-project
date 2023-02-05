#resource
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}

#creating resoutce2
resource "aws_key_pair" "deployer" {
  key_name   = "ubuntu"
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "local_file" "key" {
  content = tls_private_key.ssh.private_key_pem
  filename = "ubuntu.pem"
  file_permission  = "400"
}

data "aws_ami" "ubuntu" {
most_recent = true
owners = ["amazon"]

filter {
name  = "name"
values =["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
}
}

#creating public EC2 instance
resource "aws_instance" "ubuntu" {
  for_each = aws_subnet.cloud
  ami              = data.aws_ami.ubuntu.id
  subnet_id        = each.value.id
  instance_type    = "t2.micro"
  key_name         = "ubuntu"
  security_groups  = [aws_security_group.allow.id]
  associate_public_ip_address = true

  provisioner "local-exec" {
  command = "echo ${self.public_ip} >> ./host-inventory"
  }

}
