module "elasticache" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-elasticache.git?ref=v1.1.0"

  cluster_id      = local.elasticache_config.cluster_id
  engine          = local.elasticache_config.engine
  node_type       = local.elasticache_config.node_type
  num_cache_nodes = local.elasticache_config.num_cache_nodes
  engine_version  = local.elasticache_config.engine_version
  port            = local.elasticache_config.port

  # Network — nhận từ orchestrator
  subnet_ids = var.private_subnets

  # Security
  transit_encryption_enabled = true
  at_rest_encryption_enabled = true
  kms_key_arn                = local.elasticache_config.kms_key_arn

  # Full-Spec additions
  automatic_failover_enabled = local.elasticache_config.automatic_failover_enabled
  multi_az_enabled           = local.elasticache_config.multi_az_enabled

  tags = local.tags
}
