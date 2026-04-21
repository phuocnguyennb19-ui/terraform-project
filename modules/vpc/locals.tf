locals {
  # 1. Local Module Config (Support dynamic config file name)
  config_local = merge(
    try(yamldecode(file("${path.cwd}/${var.config_file}")), {}),
    var.manual_config
  )

  # 2. Context & Naming (Dependency Injection from Engine)
  env     = lookup(var.global_config, "environment", null)
  region  = lookup(var.global_config, "region", null)
  project = lookup(var.global_config, "project", null)

  app_name     = lookup(local.config_local, "app_name", null)
  service_type = lookup(local.config_local, "service_type", "infra")
  name_prefix  = local.app_name == "base" || local.app_name == null ? "${local.env}-${local.project}" : "${local.env}-${local.app_name}-${local.service_type}"

  # 3. Smart Defaults for vpc
  vpc_defaults = {
    name                       = "${local.name_prefix}-vpc"
    cidr                       = lookup(local.config_local.vpc, "cidr", null)
    azs                        = [for s in ["a", "b", "c"] : "${local.region}${s}"]
    public_subnets             = lookup(local.config_local.vpc, "public_subnets", [])
    private_subnets            = lookup(local.config_local.vpc, "private_subnets", [])
    enable_nat_gateway         = lookup(local.config_local.vpc, "enable_nat_gateway", true)
    single_nat_gateway         = lookup(local.config_local.vpc, "single_nat_gateway", false)
    enable_dns_hostnames       = lookup(local.config_local.vpc, "enable_dns_hostnames", true)
    enable_dns_support         = lookup(local.config_local.vpc, "enable_dns_support", true)
    enable_vpn_gateway         = lookup(local.config_local.vpc, "enable_vpn_gateway", false)
    manage_default_network_acl = lookup(local.config_local.vpc, "manage_default_network_acl", false)
    public_subnet_tags         = lookup(local.config_local.vpc, "public_subnet_tags", {})
    private_subnet_tags        = lookup(local.config_local.vpc, "private_subnet_tags", {})
  }
  vpc_config = merge(local.vpc_defaults, try(local.config_local.vpc, {}))

  # 4. Global Alias & Tags (Merged from Engine)
  config = local.config_local
  tags = merge(
    { Environment = local.env, Project = local.project, ManagedBy = "DylanDevOps" },
    var.tags,
    try(var.global_config.tags, {})
  )
}
