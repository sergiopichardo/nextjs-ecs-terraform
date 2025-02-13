# # Add required Docker provider block
# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 5.0"
#     }

#     docker = {
#       source  = "kreuzwerker/docker"
#       version = "~> 3.0.2"
#     }
#   }
# }

# provider "aws" {
#   region = "us-east-1"

#   default_tags {
#     tags = {
#       project_name = local.project_name
#     }
#   }
# }




# * Give Docker permission to pusher Docker Images to AWS.
# data "aws_caller_identity" "this" {}
# data "aws_ecr_authorization_token" "this" {}
# data "aws_region" "this" {}

# locals {
#   ecr_address = format("%v.dkr.ecr.%v.amazonaws.com", data.aws_caller_identity.this.account_id, data.aws_region.this.name)
#   docker_host = "unix:///var/run/docker.sock"
# }

# Update the Docker provider source
# provider "docker" {
# registry_auth {
#   address  = local.ecr_address
#   password = data.aws_ecr_authorization_token.this.password
#   username = data.aws_ecr_authorization_token.this.user_name
# }

#   host = local.docker_host
# }

# * Build our Image locally with the appropriate name to push our Image
# * to our Repository in AWS.
# resource "docker_image" "this" {
#   name = "${local.ecr_address}/${local.project_name}:latest"

#   build {
#     context    = "${path.root}/app"
#     dockerfile = "${path.root}/app/Dockerfile"
#   }
# }

# # * Push our Image to our Repository.
# resource "docker_registry_image" "this" {
#   keep_remotely = true # Do not delete the old image when a new image is built
#   name          = docker_image.this.name
# }





# # Add required Docker provider block
# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 5.0"
#     }

#     docker = {
#       source  = "kreuzwerker/docker"
#       version = "~> 3.0.2"
#     }
#   }
# }

# provider "aws" {
#   region = "us-east-1"

#   default_tags {
#     tags = {
#       project_name = local.project_name
#     }
#   }
# }




# * Give Docker permission to pusher Docker Images to AWS.
# data "aws_caller_identity" "this" {}
# data "aws_ecr_authorization_token" "this" {}
# data "aws_region" "this" {}

# locals {
#   ecr_address = format("%v.dkr.ecr.%v.amazonaws.com", data.aws_caller_identity.this.account_id, data.aws_region.this.name)
#   docker_host = "unix:///var/run/docker.sock"
# }

# Update the Docker provider source
# provider "docker" {
# registry_auth {
#   address  = local.ecr_address
#   password = data.aws_ecr_authorization_token.this.password
#   username = data.aws_ecr_authorization_token.this.user_name
# }

#   host = local.docker_host
# }

# * Build our Image locally with the appropriate name to push our Image
# * to our Repository in AWS.
# resource "docker_image" "this" {
#   name = "${local.ecr_address}/${local.project_name}:latest"

#   build {
#     context    = "${path.root}/app"
#     dockerfile = "${path.root}/app/Dockerfile"
#   }
# }

# # * Push our Image to our Repository.
# resource "docker_registry_image" "this" {
#   keep_remotely = true # Do not delete the old image when a new image is built
#   name          = docker_image.this.name
# }

