provider "aws" {
  region = var.region
  #  profile = var.profile_name
}

terraform {
#  backend "s3" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.63"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 2.2"
    }
  }
}
