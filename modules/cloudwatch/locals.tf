locals {
  # 1. Local Module Config (Support dynamic config file name)
  config_local = merge(
    try(yamldecode(file("${path.cwd}/${var.config_file}")), {}),
    var.manual_config
  )

  # 2. Context & Naming (Strict mapping from config.yml)
  env          = lookup(var.global_config, "environment", null)
  region       = lookup(var.global_config, "region", null)
  project      = lookup(var.global_config, "project", null)
  app_name     = lookup(local.config_local, "app_name", null)
  service_type = lookup(local.config_local, "service_type", "infra")
  name_prefix  = local.app_name == "base" || local.app_name == null ? "${local.env}-${local.project}" : "${local.env}-${local.app_name}-${local.service_type}"

  # 3. CloudWatch Config Mapping (Key:Value Sync)
  cw_raw = try(local.config_local.cloudwatch, {})

  # Factory mapping for log groups
  log_groups = try(local.cw_raw.log_groups, {})

  # Factory mapping for metric alarms
  metric_alarms = try(local.cw_raw.metric_alarms, {})

  tags = merge(
    { 
      Environment = local.env, 
      Project     = local.project, 
      ManagedBy   = "DylanDevOps",
      Terraform   = "true" 
    },
    var.tags, try(var.global_config.tags, {})
  )
}
