variable "lb_name" {
  description = "Name of the ALB"
  type        = string
}

variable "target_group_name" {
  description = "Name of the target group"
  type        = string
}

variable "security_groups" {
  description = "Security groups for ALB"
  type        = list(string)
}

variable "subnets" {
  description = "Subnets for ALB"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for ALB"
  type        = string
}

variable "certificate_arn" {
  description = "Certificate ARN for SSL"
  type        = string
}
