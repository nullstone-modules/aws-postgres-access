output "security_group_rules" {
  value = [
    {
      id       = local.db_security_group_id
      protocol = "tcp"
      port     = local.db_port
    }
  ]
}

output "env" {
  value = [
    {
      name  = "POSTGRES_USER"
      value = local.username
    },
    {
      name  = "POSTGRES_DB"
      value = local.database_name
    }
  ]
}

output "secrets" {
  value = [
    {
      name      = "POSTGRES_PASSWORD"
      valueFrom = aws_secretsmanager_secret.password.arn
    },
    {
      name      = "POSTGRES_URL"
      valueFrom = aws_secretsmanager_secret.url.arn
    }
  ]
}
