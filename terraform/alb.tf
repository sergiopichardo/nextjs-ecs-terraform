
# Create application load balancer
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.4.0"
  name    = "${local.project_name}-alb"

  load_balancer_type = "application"
  security_groups    = [module.vpc.default_security_group_id]
  subnets            = module.vpc.public_subnets
  vpc_id             = module.vpc.vpc_id

  security_group_rules = {
    ingress_all_http = {
      type        = "ingress"
      from_port   = var.ingress_port
      to_port     = var.ingress_port
      protocol    = "TCP"
      description = "HTTP web traffic"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  http_tcp_listeners = [
    {
      # Defaults to "forward" action for "target group"
      # at index = 0 in "the target_groups" input below.
      port               = var.ingress_port
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  target_groups = [
    {
      backend_port     = var.target_group_service_port
      backend_protocol = "HTTP"
      target_type      = "ip"
    }
  ]
}

output "load_balancer_url" {
  value       = "http://${module.alb.lb_dns_name}"
  description = "The URL of the Application Load Balancer"
}
