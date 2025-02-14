# Create our ECS Cluster.
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 5.12.0"

  cluster_name = "nextjs-ecs-terraform-fargate-cluster"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/nextjs-ecs-terraform"
      }
    }
  }

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }
}


# Create shared assume role policy for ECS tasks
data "aws_iam_policy_document" "assume_role_policy" {
  version = "2012-10-17"
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}


# Create a security group for ECS tasks
resource "aws_security_group" "ecs_tasks" {
  name        = "nextjs-ecs-terraform-ecs-tasks"
  description = "Allow inbound access from the ALB only"
  vpc_id      = module.vpc.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 3000
    to_port         = 3000
    security_groups = [module.alb.security_group_id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "this" {
  cluster                = module.ecs.cluster_id
  desired_count          = 1
  launch_type            = "FARGATE"
  name                   = "nextjs-ecs-terraform-service"
  task_definition        = aws_ecs_task_definition.this.arn
  enable_execute_command = true // terraform.workspace == "default" ? true : false

  lifecycle {
    # Allow external changes to happen without Terraform conflicts, particularly around auto-scaling.
    # if we update the designed count, we don't want terraform to destroy and recreate the services
    ignore_changes = [desired_count]
  }

  load_balancer {
    container_name   = "nextjs-ecs-terraform-container" // should it be set to 0? 
    container_port   = 3000                             // 3000 
    target_group_arn = module.alb.target_group_arns[0]
  }

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = module.vpc.private_subnets
    assign_public_ip = false
  }
}



# Task Role - for your application
resource "aws_iam_role" "ecs_task_role" {
  name               = "nextjs-ecs-terraform-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

# Task Execution Role - for ECS itself
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "nextjs-ecs-terraform-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

# Attach necessary policies to the execution role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Create CloudWatch Log Group
resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/ecs/nextjs-ecs-terraform"
  retention_in_days = 30
}

# Attach CloudWatch Logs policy to the task execution role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_cloudwatch_logs" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs.arn
}

# Create policy document for ECS Exec
data "aws_iam_policy_document" "ecs_exec" {
  statement {
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }
}

# Create IAM policy for ECS Exec
resource "aws_iam_policy" "ecs_exec" {
  name        = "nextjs-ecs-terraform-ecs-exec"
  description = "Allow ECS Exec functionality"
  policy      = data.aws_iam_policy_document.ecs_exec.json
}

# Attach ECS Exec policy to the task role (not execution role)
resource "aws_iam_role_policy_attachment" "ecs_exec" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_exec.arn
}

# CloudWatch Logs Policy
resource "aws_iam_policy" "cloudwatch_logs" {
  name        = "nextjs-ecs-terraform-cloudwatch-logs"
  description = "Allow ECS tasks to send logs to CloudWatch"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.this.arn}:*"
      }
    ]
  })
}

# Get current region
data "aws_region" "this" {}

# Get current AWS account ID
data "aws_caller_identity" "this" {}

resource "aws_ecs_task_definition" "this" {
  cpu                      = 1024
  family                   = "main-task-definition"
  memory                   = 2048
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  task_role_arn      = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    environment : [
      {
        name  = "DATABASE_URL",
        value = ""
        # value = "postgresql://${var.database_username}:${var.database_password}@${module.rds.db_instance_endpoint}/${var.database_name}"
      },
      # {
      #   name  = "HOSTNAME",
      #   value = "0.0.0.0"
      # },
      # {
      #   name  = "PORT",
      #   value = "3000"
      # },
    ],
    essential = true,
    image     = "${data.aws_caller_identity.this.account_id}.dkr.ecr.${data.aws_region.this.name}.amazonaws.com/nextjs-ecs-terraform:latest",
    name      = "nextjs-ecs-terraform-container",
    portMappings = [
      {
        containerPort = 3000
        hostPort      = 3000
      }
    ],
    healthCheck = {
      command = [
        "CMD-SHELL",
        # NOTE: this is an api route in nextjs-server-app/src/app/api/healthcheck/route.ts
        "curl -f http://localhost:3000/api/healthcheck || exit 1"
        # "curl -f http://localhost/ >> /proc/1/fd/1 2>&1  || exit 1"
        # "curl -f http://localhost:3000/api/healthcheck || exit 1"
        # "curl -s --fail -I http://0.0.0.0:${var.container_port}/ || exit 1"
      ]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 60
    },
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.this.name
        "awslogs-region"        = data.aws_region.this.name
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

