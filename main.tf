# Requirements:
# 1. Call provider
# 2. Create a VPC 
# 3. Create an Internet Gateway
# 4. Create a Custom Route Table 
# 5. Create a Subnet 
# 6. Assosiate Subnet with Route Table
# 7. Create a Secuirty Group to allow port 22 (ssh),80 (http/https),443 (http/https)
# 8. Create a network interface with the Subnet IP
# 9. Assign an elastic IP address to the Network Interface
# 10. Create Ubuntu server (install and enable apache2)

# Additional Requriements:
# 0.1 Generate outputs
# 0.2 Create a variable 


# 1. Call Provider
provider "aws" {
  region = "us-east-1"
  profile = "training"
}

resource "aws_s3_bucket" "test-bucket" {
  bucket = "test-bucket"
}

/* # 2. Create a VPC 
resource "aws_vpc" "prod" {
  cidr_block = "10.0.0.0/17"
}


# 3. Create an Internet Gateway (enables traffic to be sent to internet)
resource "aws_internet_gateway" "prod-gw" {
  vpc_id = aws_vpc.prod-vpc.id
}


# 4. Create a custom Route Table (Rules to determine where network traffic from vpc or gateway is being directed)
resource "aws_route_table" "prod-rt" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0" #enables internet gateway
    gateway_id = aws_internet_gateway.prod-gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.prod-gw.id
  }
    tags = {
    Name = "MyRouteTable"
    }
}


# 5. Create a Subnet (range of IP addresses for the VPC)
resource "aws_subnet" "prod-subnet" {
  vpc_id            = aws_vpc.prod-vpc.id
  cidr_block        = var.subnet_cidr_block # passing cidr_block as a variable 
  availability_zone = "us-east-1a"
}


# 6. Assosiate Subnet with a Route Table (connects subnet and route table together)
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.prod-subnet.id
  route_table_id = aws_route_table.prod-rt.id
}


# 7. Create a Secuirty Group to allow port 22 (ssh),80 (http/https),443 (http/https) (Determines traffic allowed to connect to the EC2 instance)
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow web traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0 # 0 is allowing all ports
    to_port     = 0
    protocol    = "-1" # -1 allows for any protocol 
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# 8. Create a network interface with the Subnet IP 
resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.prod-subnet.id
  private_ips     = ["10.0.1.50"] # passing in a list of IP's
  security_groups = [aws_security_group.allow_web.id]
}


# 9. Assign an elastic IP address to the Network Interface
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.prod-gw] # eip requires the deployment of an Internet gateway. Pass in as a list when using depends_on meta argument
}


# 10. Create Ubuntu server (install and enable apache2)
resource "aws_instance" "web-server-instance" {
  ami               = "ami-09e67e426f25ce0d7"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  key_name          = "main-key"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.web-server-nic.id
  }

  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemct1 start apache2
                sudo bash -c 'echo Check it out!!! > /var/www/html/index.html'
                EOF
}


# 0.1 Generate outputs
output "server_private_ip" {
  value = aws_instance.web-server-instance.private_ip
}

output "server_id" {
  value = aws_instance.web-server-instance.id
} */
