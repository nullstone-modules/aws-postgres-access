resource "random_password" "this" {
  // Master password length constraints differ for each database engine. For more information, see the available settings when creating each DB instance.
  length  = 16
  special = true

  // The password for the master database user can include any printable ASCII character except /, ", @, or a space.
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "password" {
  name = "${local.resource_name}/password"
  tags = data.ns_workspace.this.tags
}

resource "aws_secretsmanager_secret_version" "password" {
  secret_id     = aws_secretsmanager_secret.password.id
  secret_string = random_password.this.result
}
