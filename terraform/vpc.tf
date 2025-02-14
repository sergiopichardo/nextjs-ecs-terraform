module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "~> 5.18.0"
  name               = "nextjs-ecs-terraform-vpc"
  azs                = slice(data.aws_availability_zones.available.names, 0, 2)
  cidr               = "10.0.0.0/16"
  create_igw         = true
  enable_nat_gateway = true
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24"]
  single_nat_gateway = true
}


data "aws_availability_zones" "available" {
  state = "available"
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}


output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = join(",", module.vpc.private_subnets)
}
