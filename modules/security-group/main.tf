module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = local.sg_config.name
  description = local.sg_config.description
  vpc_id      = local.sg_config.vpc_id

  # Ingress Rules
  ingress_rules            = local.sg_config.ingress_rules
  ingress_cidr_blocks      = local.sg_config.ingress_cidr_blocks
  ingress_with_cidr_blocks = local.sg_config.ingress_with_cidr_blocks

  # Egress Rules
  egress_rules       = local.sg_config.egress_rules
  egress_cidr_blocks = local.sg_config.egress_cidr_blocks

  tags = local.tags
}
