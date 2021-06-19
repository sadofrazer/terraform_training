provider "aws" {
  region     = "us-east-1"
  shared_credentials_file = "C:/Files/Docs Perso/DevOps/AWS/.aws/credentials"
}

terraform {
  backend "s3" {
    bucket = "terraform-backend-frazer"
    key    = "frazer.tfstate"
    region = "us-east-1"
    shared_credentials_file = "C:/Files/Docs Perso/DevOps/AWS/.aws/credentials"
  }
}

resource "aws_instance" "frazer-ec2" {
  ami             = data.aws_ami.my_ami.id
  instance_type   = var.instance_type
  key_name        = "${var.ssh_key}"
  security_groups = ["${aws_security_group.my_sg.name}"]
  tags = {
    Name = "${var.author}-ec2"
  }

  root_block_device {
    delete_on_termination = true
  }

  provisioner "remote-exec" {
    inline = [
      "sudo amazon-linux-extras install -y nginx1.12",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx"
    ]

    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = file("./${var.ssh_key}.pem")
      host = self.public_ip
    }

  }
  
}

resource "aws_security_group" "my_sg" {
  name        = "${var.author}-sg"
  description = "Allow http and https inbound traffic"
  #vpc_id      = aws_vpc.main.id

  ingress {
    description      = "HTTP from all"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP from all"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  ingress {
    description      = "HTTPS from all"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.author}-sg"
  }
}

resource "aws_eip" "my_eip" {
  vpc      = true
  instance = aws_instance.frazer-ec2.id

  provisioner "local-exec" {
    command = " echo PUBLIC IP: ${self.public_ip} ; ID: ${aws_instance.frazer-ec2.id} ; AZ: ${aws_instance.frazer-ec2.availability_zone}; >> infos_ec2.txt"
   }

}

