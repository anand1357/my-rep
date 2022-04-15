provider "aws" {
  region = "${var.region}"
}
resource "aws_vpc" "myvpc" {
  cidr_block       = "${var.vpc_cidr}"

  tags = {
    Name = "my-vpc"
  }
}
resource "aws_subnet" "pubsub" { 
  vpc_id     = "${aws_vpc.myvpc.id}"
  cidr_block = var.subnet_cidr

  tags = {
    Name = "subnet"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "igw"
  }
}
resource "aws_route_table" "pubrt" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "PUBRT"
  }
}
resource "aws_route_table_association" "pubasso" {
  subnet_id      = aws_subnet.pubsub.id
  route_table_id = aws_route_table.pubrt.id
}

resource "aws_eip" "eip" {
  instance = aws_instance.publicmachine1.id
  vpc = true
}
resource "aws_eip_association" "eip_assoc" {
  instance_id  = aws_instance.publicmachine1.id
  allocation_id = aws_eip.eip.id
}
output "public_ip"{
  value = aws_instance.publicmachine1.public_ip
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all"
  }
}
resource "aws_instance" "publicmachine1" {
  ami                        = "ami-03ededff12e34e59e"
  instance_type              = "t2.micro"
  subnet_id                  = aws_subnet.pubsub.id
  key_name                   = "linux-key"
  vpc_security_group_ids     = ["${aws_security_group.allow_all.id}"]
  associate_public_ip_address = true

  
  user_data = <<EOF
#!/bin/bash
yum update -y	
yum install httpd -y
service httpd start
echo "Terraform via deployed" > /var/www/html/index.html
EOF

 
tags = {
  Name = "userdata"
  }
}
 
