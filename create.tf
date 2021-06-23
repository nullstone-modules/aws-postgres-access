data "aws_lambda_invocation" "create-user" {
  function_name = data.ns_connection.postgres.outputs.lambda_function_name

  input = sensitive(jsonencode({
    type = "create-user"
    metadata = {
      username = local.username
      password = random_password.this.result
    }
  }))
}

data "aws_lambda_invocation" "create-database" {
  function_name = data.ns_connection.postgres.outputs.db_admin_function_name

  input = jsonencode({
    type = "create-database"
    metadata = {
      databaseName = var.database_name
      owner        = local.username
    }
  })

  depends_on = [data.aws_lambda_invocation.create-user]
}
