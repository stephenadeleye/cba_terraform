provider "aws" {
  region = var.region
}

# Create a new VPC
resource "aws_vpc" "cba_tf_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "CBAterraformVPC"
  }
}

# Create an Internet Gateway attached to the VPC
resource "aws_internet_gateway" "cba_tf_igw" {
  vpc_id = aws_vpc.cba_tf_vpc.id
  tags = {
    Name = "CBAterraformIGW"
  }
}

# Create a public route table for the VPC
resource "aws_route_table" "cba_tf_public_rt" {
  vpc_id = aws_vpc.cba_tf_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cba_tf_igw.id
  }
  tags = {
    Name = "CBAterraformPublicRT"
  }
}

# Create a public subnet in the new VPC
resource "aws_subnet" "cba_tf_subnet" {
  vpc_id                  = aws_vpc.cba_tf_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = true  # Automatically assigns public IP addresses
  tags = {
    Name = "CBAterraformSubnet"
  }
}

# Associate the public subnet with the public route table
resource "aws_route_table_association" "cba_tf_subnet_assoc" {
  subnet_id      = aws_subnet.cba_tf_subnet.id
  route_table_id = aws_route_table.cba_tf_public_rt.id
}

# Create a security group in the new VPC
resource "aws_security_group" "cba_tf_sg" {
  name        = "cba_tf_sg"
  description = "allow all traffic"
  vpc_id      = aws_vpc.cba_tf_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    name = "CBAterraformSG"
  }
}

data "aws_key_pair" "sample_kp" {
  key_name = var.key_name
}

# Create an EC2 instance in the public subnet with a public IP address
resource "aws_instance" "cba_tf_instance" {
  instance_type                = var.instance_type
  ami                          = var.instance_ami
  key_name                     = var.key_name
  subnet_id                    = aws_subnet.cba_tf_subnet.id
  associate_public_ip_address  = true  # Explicitly assign a public IP
  vpc_security_group_ids       = [aws_security_group.cba_tf_sg.id]
  user_data = file("install_apache.sh")


  tags = {
    Name = "CBATerraformInstance"
  }
}
