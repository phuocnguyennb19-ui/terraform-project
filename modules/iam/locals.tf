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

  # 4. Smart Defaults for iam
  iam_defaults = {
    # Role 1: Basic Assumable Role (Service-linked)
    role_name               = "${local.name_prefix}-role"
    trusted_role_services   = lookup(local.config_local.iam, "trusted_role_services", ["ecs-tasks.amazonaws.com"])
    role_requires_mfa       = lookup(local.config_local.iam, "role_requires_mfa", false)
    custom_role_policy_arns = lookup(local.config_local.iam, "custom_role_policy_arns", [])

    # Full-Spec additions
    inline_policy_statements = lookup(local.config_local.iam, "inline_policy_statements", [])
    assume_role_policy       = lookup(local.config_local.iam, "assume_role_policy", null)
  }
  iam_config = merge(local.iam_defaults, try(local.config_local.iam, {}))

  # 5. Global Alias & Tags
  config = local.config_local
  tags = merge(
    { Environment = local.env, Project = local.project, ManagedBy = "DylanDevOps" },
    var.tags, try(var.global_config.tags, {})
  )
}
