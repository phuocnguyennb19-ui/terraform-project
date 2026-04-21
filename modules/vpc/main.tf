module "vpc" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=v5.13.0"

  name = local.vpc_config.name
  cidr = local.vpc_config.cidr

  azs             = local.vpc_config.azs
  private_subnets = local.vpc_config.private_subnets
  public_subnets  = local.vpc_config.public_subnets

  enable_nat_gateway = local.vpc_config.enable_nat_gateway
  single_nat_gateway = local.vpc_config.single_nat_gateway

  # Networking & Security
  enable_dns_hostnames       = local.vpc_config.enable_dns_hostnames
  enable_dns_support         = local.vpc_config.enable_dns_support
  enable_vpn_gateway         = local.vpc_config.enable_vpn_gateway
  manage_default_network_acl = local.vpc_config.manage_default_network_acl

  # Subnet Tags (Standard discovery tags)
  public_subnet_tags  = local.vpc_config.public_subnet_tags
  private_subnet_tags = local.vpc_config.private_subnet_tags

  # Security: Flow Logs
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60
  flow_log_traffic_type                = "ALL"

  tags = local.tags
}

