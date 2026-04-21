# Chuẩn hóa: Sử dụng module cho Security Group
module "rds_sg" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group.git?ref=v5.1.0"

  name        = "${local.name_prefix}-rds-sg"
  description = "Security group for RDS ${local.name_prefix}"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = local.rds_config.port
      to_port     = local.rds_config.port
      protocol    = "tcp"
      description = "Allow inbound traffic from VPC"
      cidr_blocks = var.vpc_cidr_block
    }
  ]

  egress_rules = ["all-all"]

  tags = local.tags
}

module "db" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-rds.git?ref=v6.10.0"

  identifier = local.rds_config.identifier

  engine                = local.rds_config.engine
  engine_version        = local.rds_config.engine_version
  family                = local.rds_config.family
  major_engine_version  = local.rds_config.major_engine_version
  instance_class        = local.rds_config.instance_class
  allocated_storage     = local.rds_config.allocated_storage
  max_allocated_storage = local.rds_config.max_allocated_storage
  storage_type          = local.rds_config.storage_type
  iops                  = local.rds_config.iops
  storage_throughput    = local.rds_config.storage_throughput

  db_name  = replace(local.name_prefix, "-", "")
  username = local.rds_config.username
  port     = local.rds_config.port

  manage_master_user_password = true

  # Network
  db_subnet_group_name   = "${local.name_prefix}-sng"
  create_db_subnet_group = true
  subnet_ids             = var.private_subnets
  vpc_security_group_ids = [module.rds_sg.security_group_id]

  # Backup & Maintenance
  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  backup_retention_period = local.rds_config.backup_retention_period
  skip_final_snapshot     = local.rds_config.skip_final_snapshot

  # High Availability & Security
  multi_az                        = local.rds_config.multi_az
  performance_insights_enabled    = local.rds_config.performance_insights_enabled
  monitoring_interval             = local.rds_config.monitoring_interval
  enabled_cloudwatch_logs_exports = local.rds_config.enabled_cloudwatch_logs_exports
  deletion_protection             = local.rds_config.deletion_protection

  tags = local.tags
}
