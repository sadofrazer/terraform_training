provider "aws" {
  region     = "us-east-1"
  access_key = "ACCESS_KEY"
  secret_key = "SECRET_KEY"
}

resource "aws_instance" "frazer-ec2" {
  ami           = "ami-0083662ba17882949"
  instance_type = "t2.micro"
  key_name      = "devops-frazer"
  tags = {
    Name = "ec2-frazer"
  }
  root_block_device {
    delete_on_termination = true
  }
}