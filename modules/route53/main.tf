module "zones" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-route53.git//modules/zones?ref=v4.1.0"

  zones = local.dns_config.zones

  tags = local.tags
}
