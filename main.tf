# Provider configuration for AWS
provider "aws" {
  region = "us-east-1"  # Change to your preferred region
}

# Create a new VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main_vpc"
  }
}

# Create an Internet Gateway for the VPC
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main_igw"
  }
}

# Create a public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true  # Ensure public IP assignment

  tags = {
    Name = "public_subnet"
  }
}

# Create a private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "private_subnet"
  }
}

# Create a route table for the public subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "public_route_table"
  }
}

# Associate the public route table with the public subnet
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Security Group to allow SSH traffic (for both public and private instances)
resource "aws_security_group" "ssh_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere (for public instance)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh_security_group"
  }
}

# Launch a public EC2 instance in the public subnet
resource "aws_instance" "public_instance" {
  ami             = "ami-06b21ccaeff8cd686"  # Replace with a valid AMI for your region
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.ssh_sg.id]
  associate_public_ip_address = true  # Ensure it gets a public IP

  tags = {
    Name = "public_instance"
  }
}

# Launch a private EC2 instance in the private subnet
resource "aws_instance" "private_instance" {
  ami             = "ami-06b21ccaeff8cd686"  # Replace with a valid AMI for your region
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.ssh_sg.id]
  associate_public_ip_address = false  # No public IP for this instance

  tags = {
    Name = "private_instance"
  }
}

