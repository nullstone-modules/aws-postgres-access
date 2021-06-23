resource "aws_secretsmanager_secret" "url" {
  name = "${local.resource_name}/url"
  tags = data.ns_workspace.this.tags
}

resource "aws_secretsmanager_secret_version" "url" {
  secret_id     = aws_secretsmanager_secret.url.id
  secret_string = "postgres://${local.username}:${random_password.this.result}@${local.db_endpoint}/${var.database_name}"
}
