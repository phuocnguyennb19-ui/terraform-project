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

  # 4. Smart Defaults for acm
  acm_defaults = {
    domain_name               = lookup(local.config_local.acm, "domain_name", null)
    subject_alternative_names = lookup(local.config_local.acm, "subject_alternative_names", [])
    validation_method         = lookup(local.config_local.acm, "validation_method", "DNS")
    wait_for_validation       = lookup(local.config_local.acm, "wait_for_validation", true)
  }
  acm_config = merge(local.acm_defaults, try(local.config_local.acm, {}))

  # 5. Global Alias & Tags
  config = local.config_local
  tags = merge(
    { Environment = local.env, Project = local.project, ManagedBy = "DylanDevOps" },
    var.tags, try(var.global_config.tags, {})
  )
}
