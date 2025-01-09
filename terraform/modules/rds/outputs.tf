output "rds_instance_endpoint" {
  value = aws_db_instance.this.endpoint
}

output "rds_instance_arn" {
  value = aws_db_instance.this.arn
}
