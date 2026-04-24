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
  app_name     = lookup(local.config_local, "app_name", "security")
  service_type = lookup(local.config_local, "service_type", "infra")
  name_prefix  = local.app_name == "base" || local.app_name == null ? "${local.env}-${local.project}" : "${local.env}-${local.app_name}-${local.service_type}"

  # 4. Security Group Configuration
  raw_sg_cfg = try(local.config_local.security_group, {})
  sg_defaults = {
    name                     = "${local.name_prefix}-sg"
    description              = try(local.raw_sg_cfg.description, "Security group managed by Terraform")
    vpc_id                   = var.vpc_id
    ingress_rules            = try(local.raw_sg_cfg.ingress_rules, [])
    ingress_cidr_blocks      = try(local.raw_sg_cfg.ingress_cidr_blocks, [])
    ingress_with_cidr_blocks = try(local.raw_sg_cfg.ingress_with_cidr_blocks, [])
    egress_rules             = try(local.raw_sg_cfg.egress_rules, ["all-all"])
    egress_cidr_blocks       = try(local.raw_sg_cfg.egress_cidr_blocks, ["0.0.0.0/0"])
  }
  sg_config = merge(local.sg_defaults, try(local.config_local.security_group, {}))

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
