locals {

  # 2. Local Module Config (Support dynamic config file name)
  config_local = merge(
    try(yamldecode(file("${path.cwd}/${var.config_file}")), {}),
    var.manual_config
  )

  # 3. Context & Naming (Strict mapping from config.yml)
  env          = lookup(var.global_config, "environment", null)
  region       = lookup(var.global_config, "region", null)
  project      = lookup(var.global_config, "project", null)
  app_name     = lookup(local.config_local, "app_name", null)
  service_type = lookup(local.config_local, "service_type", "infra")
  name_prefix  = local.app_name == "base" || local.app_name == null ? "${local.env}-${local.project}" : "${local.env}-${local.app_name}-${local.service_type}"

  # 4. ALB Configuration (Full-Spec for v9.x)
  alb_defaults = {
    name                       = "${local.name_prefix}-alb"
    internal                   = lookup(local.config_local.alb, "internal", false)
    idle_timeout               = lookup(local.config_local.alb, "idle_timeout", 60)
    enable_deletion_protection = lookup(local.config_local.alb, "enable_deletion_protection", local.env == "prod")
    drop_invalid_header_fields = lookup(local.config_local.alb, "drop_invalid_header_fields", true)
  }
  alb_config = merge(local.alb_defaults, try(local.config_local.alb, {}))

  # 4.1. Security Group Mapping
  alb_sg_config = {
    ingress_rules = lookup(local.alb_config, "security_group_ingress_rules", {})
    egress_rules  = lookup(local.alb_config, "security_group_egress_rules", { all_all = { ip_protocol = "-1", cidr_ipv4 = "0.0.0.0/0" } })
  }

  # 4.2. Listeners & Target Groups Mapping (Standardized for v9.x)
  # Nếu không khai báo trong YAML, tự tạo bộ Listener 80 mặc định (Backward Compatibility)
  listeners = lookup(local.alb_config, "listeners", {
    http80 = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_key = "default"
      }
    }
  })

  target_groups = lookup(local.alb_config, "target_groups", {
    default = {
      name_prefix = "def-"
      protocol    = "HTTP"
      port        = lookup(local.alb_config, "backend_port", 80)
      target_type = "ip"
      health_check = {
        enabled             = true
        path                = lookup(local.alb_config, "health_check_path", "/")
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 5
        interval            = 30
        matcher             = "200"
      }
    }
  })

  # 5. Global Alias & Tags
  config = local.config_local
  tags = merge(
    { 
      Environment = local.env, 
      Project     = local.project, 
      ManagedBy   = lookup(var.global_config, "managed_by", "DylanDevOps"),
      Terraform   = "true" 
    },
    var.tags, try(var.global_config.tags, {})
  )
}
