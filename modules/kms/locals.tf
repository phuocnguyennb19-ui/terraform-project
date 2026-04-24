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

  # 4. Smart Defaults for kms
  kms_defaults = {
    aliases                 = lookup(local.config_local.kms, "aliases", ["alias/${local.name_prefix}-key"])
    description             = lookup(local.config_local.kms, "description", "Master key for ${local.name_prefix}")
    deletion_window_in_days = lookup(local.config_local.kms, "deletion_window_in_days", 7)
    key_users               = lookup(local.config_local.kms, "key_users", [])
    key_administrators      = lookup(local.config_local.kms, "key_administrators", [])
  }
  kms_config = merge(local.kms_defaults, try(local.config_local.kms, {}))

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
