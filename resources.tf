#######               VPC                #######
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

#######             SUBNETS              #######
resource "aws_subnet" "public_subnet_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    "Name" = "Public Subnet A"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    "Name" = "Private Subnet B"
  }
}
#######             /SUBNETS             #######

resource "aws_internet_gateway" "igw_main" {
  vpc_id = aws_vpc.main.id

  tags = {
    "Name" = "IGW-Main"
  }
}

resource "aws_security_group" "sg_main" {
  name   = "SG-Main"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

#######             ROUTE TABLE              #######
resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_main.id
  }

  tags = {
    "Name" = "RT-Public"
  }
}

resource "aws_route_table_association" "rta_public_subnet_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.rt_public.id
}
#######             /ROUTE TABLE             #######

#######               INSTANCE               #######
resource "aws_instance" "app_server_1" {
  ami           = "ami-0f9fc25dd2506cf6d"
  instance_type = "t2.micro"
  key_name      = var.key_pair_name

  private_ip                  = "10.0.1.10"
  subnet_id                   = aws_subnet.public_subnet_a.id
  associate_public_ip_address = true
  security_groups             = [aws_security_group.sg_main.id]

  tags = {
    "Name" = "WebServer 01"
    "goal" = "web-server"
  }
}
#######              /INSTANCE               #######