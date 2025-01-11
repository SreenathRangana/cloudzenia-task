output "ecs_cluster_id" {
  value = module.ecs.ecs_cluster_id
}

output "rds_instance_endpoint" {
  value = module.rds.rds_instance_endpoint
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "secret_arn" {
  value = module.secrets_manager.secret_arn
}
