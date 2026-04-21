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

  # 4. Smart Defaults for rds
  rds_defaults = {
    identifier                      = "${local.name_prefix}-db"
    engine                          = lookup(local.config_local.rds, "engine", null)
    engine_version                  = lookup(local.config_local.rds, "engine_version", null)
    instance_class                  = lookup(local.config_local.rds, "instance_class", null)
    allocated_storage               = lookup(local.config_local.rds, "allocated_storage", 20)
    max_allocated_storage           = lookup(local.config_local.rds, "max_allocated_storage", 100)
    storage_type                    = lookup(local.config_local.rds, "storage_type", "gp3")
    iops                            = lookup(local.config_local.rds, "iops", null)
    storage_throughput              = lookup(local.config_local.rds, "storage_throughput", null)
    username                        = lookup(local.config_local.rds, "username", "admin")
    port                            = lookup(local.config_local.rds, "port", null)
    family                          = lookup(local.config_local.rds, "family", null)
    major_engine_version            = lookup(local.config_local.rds, "major_engine_version", null)
    backup_retention_period         = lookup(local.config_local.rds, "backup_retention_period", 7)
    skip_final_snapshot             = lookup(local.config_local.rds, "skip_final_snapshot", true)
    multi_az                        = lookup(local.config_local.rds, "multi_az", local.env == "prod")
    performance_insights_enabled    = lookup(local.config_local.rds, "performance_insights_enabled", false)
    monitoring_interval             = lookup(local.config_local.rds, "monitoring_interval", 0)
    enabled_cloudwatch_logs_exports = lookup(local.config_local.rds, "enabled_cloudwatch_logs_exports", [])
    deletion_protection             = lookup(local.config_local.rds, "deletion_protection", local.env == "prod")
  }
  rds_config = merge(local.rds_defaults, try(local.config_local.rds, {}))

  # 5. Global Alias & Tags
  config = local.config_local
  tags = merge(
    { Environment = local.env, Project = local.project, ManagedBy = "DylanDevOps" },
    var.tags, try(var.global_config.tags, {})
  )
}
