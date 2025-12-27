resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
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

data "aws_subnet" "subnet" {
  vpc_id            = aws_default_vpc.default.id
  availability_zone = "ap-south-1a" # Example AZ
}

output "vpc" {
  value = aws_default_vpc.default.id
}

resource "aws_security_group" "security-group" {
  vpc_id      = aws_default_vpc.default.id
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
  instance_type               = "t3.medium"
  key_name                    = "ssh-key2"
  subnet_id                   = data.aws_subnet.subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.security-group.id]

  tags = {
    Name = "Jenkins-server"
  }
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key =  file(var.ssh_private_key_path)
    host        = self.public_ip
  }
  provisioner "file" {
    source      = "jenkins.sh"
    destination = "/tmp/jenkins.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/jenkins.sh",
      "sudo /tmp/jenkins.sh"
    ]
  }

}

resource "aws_instance" "sonar_server" {
  ami                         = data.aws_ami.name.id
  instance_type               = "t3.medium"
  key_name                    = "ssh-key2"
  subnet_id                   = data.aws_subnet.subnet.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.instance-profile.name
  vpc_security_group_ids      = [aws_security_group.security-group.id]
  tags = {
    Name = "Sonar-server"
  }
  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.ssh_private_key_path)
    host        = self.public_ip
  }
  provisioner "file" {
    source      = "sonar.sh"
    destination = "/tmp/sonar.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/sonar.sh",
      "sudo /tmp/sonar.sh"
    ]
  }
}