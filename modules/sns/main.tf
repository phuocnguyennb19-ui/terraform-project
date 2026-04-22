module "sns" {
  for_each = local.topics
  source   = "git::https://github.com/terraform-aws-modules/terraform-aws-sns.git?ref=v6.1.1"

  name = lookup(each.value, "name", "${local.name_prefix}-${each.key}")

  display_name = lookup(each.value, "display_name", null)
  fifo_topic   = lookup(each.value, "fifo_topic", false)

  subscriptions = lookup(each.value, "subscriptions", {})

  tags = local.tags
}
