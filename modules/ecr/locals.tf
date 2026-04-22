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

  # 4. ECR Config (Full-Spec)
  ecr_defaults = {
    repository_names     = lookup(local.config_local.ecr, "repository_names", ["${local.name_prefix}-app"])
    image_tag_mutability = lookup(local.config_local.ecr, "image_tag_mutability", "MUTABLE")
    scan_on_push         = lookup(local.config_local.ecr, "scan_on_push", true)

    # Full-Spec additions
    lifecycle_policy = lookup(local.config_local.ecr, "lifecycle_policy", null)
  }
  ecr_config = merge(local.ecr_defaults, try(local.config_local.ecr, {}))

  # 5. Global Alias & Tags
  config = local.config_local
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
