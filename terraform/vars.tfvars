# VPC 
vpc_name                = "nextjs-ecs-terraform-vpc"
availability_zones      = ["us-east-1a", "us-east-1b"]
vpc_cidr_block          = "10.0.0.0/16"
enable_internet_gateway = true
enable_nat_gateway      = true
private_subnets         = ["10.0.1.0/24", "10.0.2.0/24"]
public_subnets          = ["10.0.101.0/24", "10.0.102.0/24"]
single_nat_gateway      = true


# ECS
region           = "us-east-1"
container_port   = 3000
container_cpu    = 1024 # 1 vCPU
container_memory = 2048 # 2GB RAM


# RDS 
database_instance_name       = "nextjs-ecs-terraform-db"
database_security_group_name = "nextjs-ecs-terraform-db-sg"

deletion_protection           = false
database_port                 = 5432
database_name                 = "nextjsecsterraform"
database_username             = "nextjsecsterraform"
database_password             = "nextjsecsterraform"
database_instance_class       = "db.t3.micro"
database_allocated_storage    = 20
database_engine               = "postgres"
database_engine_version       = "16.3"
database_major_engine_version = "16"
database_family               = "postgres16"


# S3 
bucket_name = "nextjs-ecs-terraform-assets"


# ALB 
ingress_port              = 80
target_group_service_port = 3000
