resource "aws_secretsmanager_secret" "db_credentials" {
  name        = var.secret_name
  description = "RDS Database credentials for WordPress"
}

resource "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id     = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_user
    password = var.db_password
  })
}
