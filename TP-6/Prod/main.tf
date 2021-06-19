provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "C:/Files/Docs Perso/DevOps/AWS/.aws/credentials"
}

terraform {
  backend "s3" {
    bucket                  = "terraform-backend-frazer"
    key                     = "frazer-prod.tfstate"
    region                  = "us-east-1"
    shared_credentials_file = "C:/Files/Docs Perso/DevOps/AWS/.aws/credentials"
  }
}


module "ec2module" {
  source        = "../modules/ec2module"
  author        = "Frazer-Prod"
  instance_type = "t2.micro"

}