/*
**********************************
* VPC 
**********************************
*/

variable "vpc_name" {
  type        = string
  description = "The name of the VPC"

  validation {
    condition     = var.vpc_name != ""
    error_message = "VPC name must not be empty"
  }
}

variable "availability_zones" {
  type        = list(string)
  description = "The availability zones to deploy the VPC in"

  validation {
    condition     = var.availability_zones != "" && length(var.availability_zones) >= 2
    error_message = <<-EOF
      Availability zones must not be empty.
      Please provide at least two availability zones to deploy the VPC in.
      Example: ["us-east-1a", "us-east-1b"]
    EOF
  }
}

variable "vpc_cidr_block" {
  type        = string
  description = "The CIDR block for the VPC"

  validation {
    condition     = var.vpc_cidr_block != ""
    error_message = <<-EOF
      VPC CIDR block must not be empty.
      Please provide a valid CIDR block for the VPC.
      Example: "10.0.0.0/16"
    EOF
  }
}

variable "enable_internet_gateway" {
  type        = bool
  description = "Whether to create an internet gateway for the VPC"

  validation {
    condition     = var.enable_internet_gateway != null
    error_message = "Enable internet gateway must not be empty"
  }
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Whether to enable a NAT gateway for the VPC"

  validation {
    condition     = var.enable_nat_gateway != ""
    error_message = "Enable NAT gateway must not be empty"
  }
}


variable "private_subnets" {
  type        = list(string)
  description = "The private subnets to deploy the VPC in"

  validation {
    condition     = var.private_subnets != "" && length(var.private_subnets) >= 2
    error_message = <<-EOF
      Private subnets must not be empty.
      Please provide at least two private subnets to deploy the VPC in.
      Example: ["10.0.1.0/24", "10.0.2.0/24"]
    EOF
  }
}

variable "public_subnets" {
  type        = list(string)
  description = "The public subnets to deploy the VPC in"

  validation {
    condition     = var.public_subnets != "" && length(var.public_subnets) >= 2
    error_message = <<-EOF
      Public subnets must not be empty.
      Please provide at least two public subnets to deploy the VPC in.
      Example: ["10.0.101.0/24", "10.0.102.0/24"]
    EOF
  }
}

variable "single_nat_gateway" {
  type        = bool
  description = "Whether to create a single NAT gateway for the VPC"

  validation {
    condition     = var.single_nat_gateway != ""
    error_message = "Single NAT gateway must not be empty"
  }
}



/*
**********************************
* ECS
**********************************
*/

variable "region" {
  type        = string
  description = "The region to deploy the resources to"

  validation {
    condition     = var.region != ""
    error_message = "Region must not be empty"
  }
}

variable "container_port" {
  type        = number
  description = "The port on which the container listens"

  validation {
    condition     = var.container_port >= 1 && var.container_port <= 65535
    error_message = "Container port must be between 1 and 65535"
  }
}

variable "container_cpu" {
  type        = number
  description = "The number of CPU units for the container"

  validation {
    condition     = var.container_cpu >= 128 && var.container_cpu <= 2048
    error_message = "Container CPU must be between 128 and 2048"
  }
}

variable "container_memory" {
  type        = number
  description = "The amount of memory for the container"

  validation {
    condition     = var.container_memory >= 256 && var.container_memory <= 16384
    error_message = "Container memory must be between 256 and 16384"
  }
}


/*
**********************************
* RDS
**********************************
*/

variable "database_instance_name" {
  description = "Name of the RDS instance"
  type        = string

  validation {
    condition     = length(var.database_instance_name) >= 3 && length(var.database_instance_name) <= 63
    error_message = <<-EOT
      Database instance name must be between 3 and 63 characters.
      Example: my-database-instance
    EOT
  }
}

variable "database_security_group_name" {
  description = "Name of the security group for RDS"
  type        = string
  validation {
    condition     = length(var.database_security_group_name) >= 3
    error_message = <<-EOT
      Security group name must be at least 3 characters.
      Example: rds-security-group
    EOT
  }
}

variable "deletion_protection" {
  description = "If the DB instance should have deletion protection enabled"
  type        = bool
}

variable "database_name" {
  description = "Name of the database to create"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.database_name))
    error_message = <<-EOT
      Database name must start with a letter and contain only alphanumeric characters and underscores.
      Example: my_database
    EOT
  }
}

variable "database_port" {
  description = "Port on which the database accepts connections"
  type        = string
  validation {
    condition     = can(tonumber(var.database_port)) && tonumber(var.database_port) >= 1024 && tonumber(var.database_port) <= 65535
    error_message = <<-EOT
      Database port must be a valid port number between 1024 and 65535.
      Example: 5432
    EOT
  }
}

variable "database_username" {
  description = "Username for the master DB user"
  type        = string
  validation {
    condition     = length(var.database_username) >= 1 && length(var.database_username) <= 63
    error_message = <<-EOT
      Database username must be between 1 and 63 characters.
      Example: dbadmin
    EOT
  }
}

variable "database_password" {
  description = "Password for the master DB user"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.database_password) >= 8
    error_message = <<-EOT
      Database password must be at least 8 characters long.
      Example: MySecureP@ssw0rd
    EOT
  }
}

variable "database_instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
  validation {
    condition     = can(regex("^db\\.", var.database_instance_class))
    error_message = <<-EOT
      Instance class must start with 'db.'.
      Example: db.t3.micro
    EOT
  }
}

variable "database_allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = number
  validation {
    condition     = var.database_allocated_storage >= 20 && var.database_allocated_storage <= 65536
    error_message = <<-EOT
      Allocated storage must be between 20 and 65536 GB.
      Example: 20
    EOT
  }
}

variable "database_engine" {
  description = "The database engine to use"
  type        = string
  validation {
    condition     = contains(["postgres", "mysql", "mariadb", "oracle-ee", "sqlserver-ee", "sqlserver-se", "sqlserver-ex", "sqlserver-web"], var.database_engine)
    error_message = <<-EOT
      Database engine must be one of: postgres, mysql, mariadb, oracle-ee, sqlserver-ee, sqlserver-se, sqlserver-ex, sqlserver-web.
      Example: postgres
    EOT
  }
}

variable "database_engine_version" {
  description = "The engine version to use"
  type        = string
  validation {
    condition     = can(regex("^\\d+\\.\\d+(\\.\\d+)?$", var.database_engine_version))
    error_message = <<-EOT
      Engine version must be in the format 'major.minor' or 'major.minor.patch'.
      Example: 16.3
    EOT
  }
}

variable "database_major_engine_version" {
  description = "The major engine version"
  type        = string
  validation {
    condition     = can(regex("^\\d+$", var.database_major_engine_version))
    error_message = <<-EOT
      Major engine version must be a number.
      Example: 16
    EOT
  }
}

variable "database_family" {
  description = "The family of the RDS instance"
  type        = string

  validation {
    condition     = contains(["postgres16"], var.database_family)
    error_message = <<-EOT
      Database family must be one of: postgres16.
      Example: postgres16
    EOT
  }
}



/*
**********************************
* S3
**********************************
*/

variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket"
}



/*
**********************************
* ALB
**********************************
*/

variable "ingress_port" {
  description = "Port for ingress traffic to the load balancer"
  type        = number
  validation {
    condition     = var.ingress_port > 0 && var.ingress_port <= 65535
    error_message = <<-EOT
      Ingress port must be between 1 and 65535.
      Example: 80
    EOT
  }
}

variable "target_group_service_port" {
  description = "Port that the target group forwards traffic to"
  type        = number
  validation {
    condition     = var.target_group_service_port > 0 && var.target_group_service_port <= 65535
    error_message = <<-EOT
      Target group service port must be between 1 and 65535.
      Example: 3000
    EOT
  }
}


