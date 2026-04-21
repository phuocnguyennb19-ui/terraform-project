module "secrets_manager" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-secrets-manager.git?ref=v1.1.0"

  name        = local.secrets_manager_config.name
  description = local.secrets_manager_config.description

  recovery_window_in_days = local.secrets_manager_config.recovery_window_in_days

  kms_key_id = local.secrets_manager_config.kms_key_id

  tags = local.tags
}
