module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "~> 5.18.0"
  name               = var.vpc_name
  azs                = slice(data.aws_availability_zones.available.names, 0, 2)
  cidr               = var.vpc_cidr_block
  create_igw         = var.enable_internet_gateway
  enable_nat_gateway = var.enable_nat_gateway
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
  single_nat_gateway = var.single_nat_gateway
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
  # e.g. "subnet-0123456789abcdefg,subnet-0123456789abcdefh,subnet-0123456789abcdefi"
  value = join(",", module.vpc.private_subnets)
}
