module "s3_bucket" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git?ref=v4.2.1"

  bucket = local.s3_config.bucket
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  block_public_acls       = local.s3_config.block_public_acls
  block_public_policy     = local.s3_config.block_public_policy
  ignore_public_acls      = true
  restrict_public_buckets = true

  versioning = {
    enabled = local.s3_config.versioning_enabled
  }

  server_side_encryption_configuration = local.s3_config.kms_key_id != null ? {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = local.s3_config.kms_key_id
        sse_algorithm     = "aws:kms"
      }
    }
    } : {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule      = local.s3_config.lifecycle_rule
  cors_rule           = local.s3_config.cors_rule
  logging             = local.s3_config.logging
  acceleration_status = local.s3_config.acceleration_status

  tags = local.tags
}
