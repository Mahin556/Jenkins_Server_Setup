terraform {
  backend "s3" {
    bucket       = "mahin-raza-s3-bucket"
    region       = "ap-south-1"
    key          = "Jenkins-Server-TF/terraform.tfstate"
    use_lockfile = true
    encrypt      = true
  }
  required_version = ">= 1.12.0"
  required_providers {
    aws = {
      version = ">= 6.0.0"
      source  = "hashicorp/aws"
    }
  }
}