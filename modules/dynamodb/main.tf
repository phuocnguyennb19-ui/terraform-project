module "dynamodb_table" {
  for_each = local.tables
  source   = "git::https://github.com/terraform-aws-modules/terraform-aws-dynamodb-table.git?ref=v4.1.0"

  name     = lookup(each.value, "name", "${local.name_prefix}-${each.key}")
  hash_key = lookup(each.value, "hash_key", "id")

  attributes = lookup(each.value, "attributes", [
    {
      name = "id"
      type = "S"
    }
  ])

  billing_mode   = lookup(each.value, "billing_mode", "PAY_PER_REQUEST")
  read_capacity  = lookup(each.value, "read_capacity", null)
  write_capacity = lookup(each.value, "write_capacity", null)

  tags = local.tags
}
