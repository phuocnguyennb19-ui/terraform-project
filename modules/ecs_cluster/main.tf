module "ecs" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ecs.git?ref=v5.11.4"

  cluster_name = local.ecs_config.cluster_name

  cluster_settings = [
    {
      name  = "containerInsights"
      value = local.ecs_config.container_insights ? "enabled" : "disabled"
    }
  ]

  cluster_configuration = {
    execute_command_configuration = {
      kms_key_id = local.ecs_config.kms_key_id
      logging    = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/${local.ecs_config.cluster_name}/execute-command"
      }
    }
  }

  default_capacity_provider_use_fargate = true

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = local.ecs_config.fargate_weight
        base   = local.ecs_config.fargate_base
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = local.ecs_config.fargate_spot_weight
      }
    }
  }

  tags = local.tags
}
