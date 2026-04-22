# Chuẩn hóa: Sử dụng module cho Target Group & Listener Rule
module "lb_resources" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  create_lb = false

  target_groups = [
    {
      name_prefix      = "h"
      backend_protocol = "HTTP"
      backend_port     = lookup(local.service_cfg.load_balancer, "container_port", 80)
      target_type      = "ip"
      health_check = {
        enabled             = true
        path                = lookup(local.service_cfg, "health_check_path", "/")
        healthy_threshold   = 2
        unhealthy_threshold = 3
        timeout             = 5
        interval            = 30
        matcher             = "200"
      }
    }
  ]

  http_tcp_listener_rules = var.listener_arn != null && var.listener_arn != "" ? [
    {
      http_listener_arn = var.listener_arn
      priority          = lookup(local.service_cfg, "priority", 100)
      actions = [
        {
          type               = "forward"
          target_group_index = 0
        }
      ]
      conditions = [
        {
          host_headers = [lookup(local.service_cfg, "host_header", "${local.app_name}.${local.env}.internal")]
        }
      ]
    }
  ] : []

  tags = local.tags
}

# --- ECS Service ---
module "ecs_service" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ecs.git//modules/service?ref=v5.11.4"

  name        = local.name_prefix
  cluster_arn = var.cluster_arn

  # Task Level Configuration
  cpu                      = local.task_cfg.cpu
  memory                   = local.task_cfg.memory
  network_mode             = local.task_cfg.network_mode
  requires_compatibilities = local.task_cfg.requires_compatibilities

  task_exec_iam_role_arn = local.task_cfg.execution_role_arn
  tasks_iam_role_arn     = local.task_cfg.task_role_arn

  # Container Definitions
  container_definitions = local.containers

  # Volumes
  volume = local.task_cfg.volumes

  # Service Level Configuration
  desired_count                      = local.service_cfg.desired_count
  deployment_maximum_percent         = local.service_cfg.deployment_maximum_percent
  deployment_minimum_healthy_percent = local.service_cfg.deployment_minimum_healthy_percent

  # Network
  subnet_ids         = local.service_cfg.subnet_ids != null ? local.service_cfg.subnet_ids : var.private_subnets
  security_group_ids = local.service_cfg.security_group_ids != null ? local.service_cfg.security_group_ids : null

  # Tự động tạo SG rules nếu không truyền security_group_ids
  create_security_group = local.service_cfg.security_group_ids == null
  security_group_rules  = local.ecs_sg_rules

  # Load Balancer Attachment (Dùng ARN từ module target_group)
  load_balancer = lookup(local.service_cfg.load_balancer, "container_name", "") != "" ? {
    service = {
      target_group_arn = module.lb_resources.target_group_arns[0]
      container_name   = local.service_cfg.load_balancer.container_name
      container_port   = local.service_cfg.load_balancer.container_port
    }
  } : {}

  # Runtime & Deployment Configuration
  health_check_grace_period_seconds = local.service_cfg.health_check_grace_period
  enable_execute_command            = local.service_cfg.enable_execute_command
  force_new_deployment              = local.service_cfg.force_new_deployment
  
  deployment_circuit_breaker = {
    enable   = true
    rollback = true
  }

  propagate_tags = local.service_cfg.propagate_tags

  # AutoScaling tích hợp (Integrated)
  enable_autoscaling       = local.autoscaling_cfg.enabled
  autoscaling_min_capacity = local.autoscaling_cfg.min_capacity
  autoscaling_max_capacity = local.autoscaling_cfg.max_capacity
  autoscaling_policies     = local.autoscaling_policies

  tags = local.tags
}
