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

  # 4. Smart Defaults for elasticache
  elasticache_defaults = {
    cluster_id      = "${local.name_prefix}-redis"
    node_type       = lookup(local.config_local.elasticache, "node_type", "cache.t3.micro")
    engine          = lookup(local.config_local.elasticache, "engine", "redis")
    engine_version  = lookup(local.config_local.elasticache, "engine_version", "7.0")
    num_cache_nodes = lookup(local.config_local.elasticache, "num_cache_nodes", 1)
    port            = lookup(local.config_local.elasticache, "port", 6379)
    kms_key_arn     = lookup(local.config_local.elasticache, "kms_key_arn", null)

    # Full-Spec additions
    automatic_failover_enabled = lookup(local.config_local.elasticache, "automatic_failover_enabled", false)
    multi_az_enabled           = lookup(local.config_local.elasticache, "multi_az_enabled", false)
  }
  elasticache_config = merge(local.elasticache_defaults, try(local.config_local.elasticache, {}))

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
