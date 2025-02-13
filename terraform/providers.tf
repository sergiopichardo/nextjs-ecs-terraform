terraform {
  required_version = "~> 1.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket  = "state-nextjs-ecs-terraform"
    region  = "us-east-1"
    key     = "state/terraform.tfstate"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
}

