output "ecs_cluster_id" {
  value = aws_ecs_cluster.this.id
}

output "ecs_service_id" {
  value = aws_ecs_service.wordpress_service.id
}

output "ecs_task_definition_arn" {
  value = aws_ecs_task_definition.wordpress.arn
}
