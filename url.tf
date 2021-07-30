resource "aws_secretsmanager_secret" "url" {
  name = "${local.resource_name}/url"
  tags = data.ns_workspace.this.tags
}

resource "aws_secretsmanager_secret_version" "url" {
  secret_id     = aws_secretsmanager_secret.url.id
  secret_string = "postgres://${urlencode(local.username)}:${urlencode(random_password.this.result)}@${local.db_endpoint}/${urlencode(local.database_name)}"
}
