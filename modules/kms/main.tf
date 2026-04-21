module "kms" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-kms.git?ref=v2.2.1"

  description             = local.kms_config.description
  deletion_window_in_days = local.kms_config.deletion_window_in_days

  # Security: Key Rotation (Mandatory)
  enable_key_rotation = true

  aliases = local.kms_config.aliases

  key_users          = local.kms_config.key_users
  key_administrators = local.kms_config.key_administrators

  tags = local.tags
}

