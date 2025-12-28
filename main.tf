resource "aws_vpc" "jenkins_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "Jenkins VPC"
  }
}

data "aws_ami" "name" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_availability_zones" "zones" {
  state = "available"
}

resource "aws_subnet" "public_subnets1" {
  vpc_id            = aws_vpc.jenkins_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.zones.names[0]
}

resource "aws_subnet" "public_subnets2" {
  vpc_id            = aws_vpc.jenkins_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.zones.names[1]
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.jenkins_vpc.id
  tags = {
    Name = "Jenkins-IGW"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.jenkins_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "Jenkins-Public-RT"
  }
}

resource "aws_route_table_association" "public_rt1" {
  subnet_id      = aws_subnet.public_subnets1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt2" {
  subnet_id      = aws_subnet.public_subnets2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "security-group" {
  vpc_id      = aws_vpc.jenkins_vpc.id
  description = "Allowing Jenkins, Sonarqube, SSH Access"
  ingress = [
    for port in [22, 8080, 9000, 9090, 80, 443, 3000, 3500, 27017] : {
      description      = "TLS from VPC"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      ipv6_cidr_blocks = ["::/0"]
      self             = false
      prefix_list_ids  = []
      security_groups  = []
      cidr_blocks      = ["0.0.0.0/0"]
    }
  ]
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = var.sg_name
  }
}

resource "aws_instance" "jenkins_server" {
  ami                         = data.aws_ami.name.id
  instance_type               = "t3.small"
  key_name                    = var.ssh_key_name
  subnet_id                   = aws_subnet.public_subnets1.id
  iam_instance_profile        = aws_iam_instance_profile.instance-profile.name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.security-group.id]
  tags = {
    Name = "Jenkins-server"
  }
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }
  user_data = file("jenkins.sh")
}

resource "aws_instance" "sonar_server" {
  ami                         = data.aws_ami.name.id
  instance_type               = "t3.small"
  key_name                    = var.ssh_key_name
  subnet_id                   = aws_subnet.public_subnets2.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.security-group.id]
  tags = {
    Name = "Sonar-server"
  }
  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }
  user_data = file("sonar.sh")
}