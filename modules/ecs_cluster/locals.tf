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

  # 4. Smart Mapping for ecs/ecs_cluster
  raw_ecs_config = merge(
    try(local.config_local.ecs, {}),
    try(local.config_local.ecs_cluster, {})
  )

  ecs_defaults = {
    cluster_name        = "${local.name_prefix}-cluster"
    container_insights  = lookup(local.raw_ecs_config, "container_insights", true)
    kms_key_id          = lookup(local.raw_ecs_config, "kms_key_id", null)
    fargate_weight      = lookup(local.raw_ecs_config, "fargate_weight", 100)
    fargate_base        = lookup(local.raw_ecs_config, "fargate_base", 0)
    fargate_spot_weight = lookup(local.raw_ecs_config, "fargate_spot_weight", 0)
  }
  ecs_config = merge(local.ecs_defaults, local.raw_ecs_config)

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
