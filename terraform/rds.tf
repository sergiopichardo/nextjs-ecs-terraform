# module "rds" {
#   source = "terraform-aws-modules/rds/aws"

#   family               = var.database_family
#   identifier           = var.database_instance_name
#   major_engine_version = var.database_major_engine_version
#   engine               = var.database_engine
#   engine_version       = var.database_engine_version

#   instance_class    = var.database_instance_class
#   allocated_storage = var.database_allocated_storage

#   db_name  = var.database_name
#   username = var.database_username
#   password = var.database_password
#   port     = var.database_port

#   iam_database_authentication_enabled = true

#   vpc_security_group_ids = [aws_security_group.rds.id]

#   create_db_subnet_group = true
#   subnet_ids             = module.vpc.private_subnets


#   # Database Deletion Protection
#   # TODO: Set to true when ready for production
#   deletion_protection = var.deletion_protection

#   # TODO: Set maintenance window and backup window
#   # maintenance_window = "Mon:00:00-Mon:03:00"
#   # backup_window      = "03:00-06:00"

#   # TODO: Set Enhanced Monitoring if we need to
#   # this is kind of expensive, so we should only do it if we need to
#   # Enhanced Monitoring - see example for details on how to create the role
#   # by yourself, in case you don't want to create it automatically
#   # monitoring_interval    = "60"
#   # monitoring_role_name   = "MyRDSMonitoringRole"
#   # create_monitoring_role = true
# }

# # Add this security group resource
# resource "aws_security_group" "rds" {
#   name        = var.database_security_group_name
#   description = "Grants access to the RDS instance from the ECS tasks"
#   vpc_id      = module.vpc.vpc_id

#   ingress {
#     description     = "PostgreSQL access from ECS service"
#     from_port       = var.database_port
#     to_port         = var.database_port
#     protocol        = "tcp"
#     security_groups = [aws_security_group.ecs_tasks.id]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }



# output "database_connection_url" {
#   description = "PostgreSQL connection string for Prisma"
#   value       = "postgresql://${var.database_username}:${var.database_password}@${module.rds.db_instance_endpoint}/${var.database_name}?schema=public"
#   sensitive   = true
# }

# output "rds_security_group_id" {
#   description = "The ID of the RDS security group"
#   value       = aws_security_group.rds.id
# }
