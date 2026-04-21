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

  # 4. Smart Defaults for waf
  waf_defaults = {
    name           = "${local.name_prefix}-waf"
    description    = lookup(local.config_local.waf, "description", "WAF managed by Terraform for ${local.name_prefix}")
    scope          = lookup(local.config_local.waf, "scope", "REGIONAL")
    default_action = lookup(local.config_local.waf, "default_action", "allow")
    rules          = lookup(local.config_local.waf, "rules", [])
  }
  waf_config = merge(local.waf_defaults, try(local.config_local.waf, {}))

  # 5. Global Alias & Tags
  config = local.config_local
  tags = merge(
    { Environment = local.env, Project = local.project, ManagedBy = "DylanDevOps" },
    var.tags, try(var.global_config.tags, {})
  )
}
