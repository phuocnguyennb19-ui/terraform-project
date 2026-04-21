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

  # 4. Smart Defaults for secrets-manager
  secrets_manager_defaults = {
    name                    = "${local.name_prefix}-secret"
    description             = lookup(local.config_local.secrets_manager, "description", "Secret managed by Terraform for ${local.name_prefix}")
    recovery_window_in_days = lookup(local.config_local.secrets_manager, "recovery_window_in_days", 7)
    kms_key_id              = lookup(local.config_local.secrets_manager, "kms_key_id", null)
  }
  secrets_manager_config = merge(local.secrets_manager_defaults, try(local.config_local.secrets_manager, {}))

  # 5. Global Alias & Tags
  config = local.config_local
  tags = merge(
    { Environment = local.env, Project = local.project, ManagedBy = "DylanDevOps" },
    var.tags, try(var.global_config.tags, {})
  )
}
