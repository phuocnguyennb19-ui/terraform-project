module "wafv2" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-wafv2.git?ref=v1.1.0"

  name        = local.waf_config.name
  description = local.waf_config.description
  scope       = local.waf_config.scope

  default_action = local.waf_config.default_action

  rules = local.waf_config.rules

  visibility_config = {
    cloudwatch_metrics_enabled = true
    metric_name                = local.waf_config.name
    sampled_requests_enabled   = true
  }

  tags = local.tags
}
