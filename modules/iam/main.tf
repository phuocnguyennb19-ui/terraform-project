module "iam_assumable_role" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-assumable-role?ref=v5.44.0"

  create_role             = true
  role_name               = local.iam_config.role_name
  role_requires_mfa       = local.iam_config.role_requires_mfa
  trusted_role_services   = local.iam_config.trusted_role_services
  custom_role_policy_arns = local.iam_config.custom_role_policy_arns

  # Custom trust policy (if provided)
  create_custom_role_trust_policy = local.iam_config.assume_role_policy != null ? true : false
  custom_role_trust_policy        = local.iam_config.assume_role_policy

  tags = local.tags
}
