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

  # 4. Smart Defaults for s3
  s3_defaults = {
    bucket              = "${local.name_prefix}-bucket"
    versioning_enabled  = lookup(local.config_local.s3, "versioning_enabled", true)
    kms_key_id          = lookup(local.config_local.s3, "kms_key_id", null)
    block_public_acls   = lookup(local.config_local.s3, "block_public_acls", true)
    block_public_policy = lookup(local.config_local.s3, "block_public_policy", true)

    # Full-Spec additions
    lifecycle_rule      = lookup(local.config_local.s3, "lifecycle_rule", [])
    cors_rule           = lookup(local.config_local.s3, "cors_rule", [])
    logging             = lookup(local.config_local.s3, "logging", {})
    acceleration_status = lookup(local.config_local.s3, "acceleration_status", null)
  }
  s3_config = merge(local.s3_defaults, try(local.config_local.s3, {}))

  # 5. Global Alias & Tags
  config = local.config_local
  tags = merge(
    { Environment = local.env, Project = local.project, ManagedBy = "DylanDevOps" },
    var.tags, try(var.global_config.tags, {})
  )
}
