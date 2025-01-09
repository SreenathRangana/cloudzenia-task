variable "cluster_name" {
  description = "Name of the ECS Cluster"
  type        = string
}

variable "wordpress_image" {
  description = "Docker image for WordPress"
  type        = string
}

variable "db_host" {
  description = "RDS Database Host"
  type        = string
}

variable "db_user" {
  description = "RDS Database Username"
  type        = string
}

variable "db_password" {
  description = "RDS Database Password"
  type        = string
}

variable "subnets" {
  description = "Subnets for ECS Service"
  type        = list(string)
}

variable "security_groups" {
  description = "Security groups for ECS Service"
  type        = list(string)
}

variable "execution_role_arn" {
  description = "IAM Execution Role ARN for ECS"
  type        = string
}

variable "task_role_arn" {
  description = "IAM Task Role ARN for ECS"
  type        = string
}

variable "target_group_arn" {
  description = "Target Group ARN for ALB"
  type        = string
}
