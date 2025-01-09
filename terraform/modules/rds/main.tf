resource "aws_db_instance" "this" {
  allocated_storage    = var.allocated_storage
  engine               = "mysql"
  instance_class       = var.instance_class
  name                 = var.db_name
  username             = var.username
  password             = var.password
  publicly_accessible  = false
  skip_final_snapshot  = true
  multi_az             = var.multi_az
  vpc_security_group_ids = var.security_groups
  subnet_ids           = var.subnet_ids
  backup_retention_period = 7
  backup_window           = "03:00-06:00"
}
