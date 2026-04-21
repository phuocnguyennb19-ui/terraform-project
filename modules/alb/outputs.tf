output "lb_id" { value = module.alb.id }
output "lb_arn" { value = module.alb.arn }
output "lb_dns_name" { value = module.alb.dns_name }
output "lb_zone_id" { value = module.alb.zone_id }

# V9 Migration: Listeners & Target Groups hiện là Maps
output "listeners" { value = module.alb.listeners }
output "target_groups" { value = module.alb.target_groups }

# Backward Compatibility cho Engine cũ (nếu cần)
output "http_tcp_listener_arns" {
  value = [for k, v in module.alb.listeners : v.arn]
}

output "target_group_arns" {
  value = [for k, v in module.alb.target_groups : v.arn]
}
