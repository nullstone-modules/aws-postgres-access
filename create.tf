data "aws_lambda_invocation" "create-user" {
  function_name = data.ns_connection.postgres.outputs.db_admin_function_name

  // TODO: Wrap with sensitive when upgraded to TF 0.15
  input = jsonencode({
    type = "create-user"
    metadata = {
      username = local.username
      password = random_password.this.result
    }
  })
}

data "aws_lambda_invocation" "create-database" {
  function_name = data.ns_connection.postgres.outputs.db_admin_function_name

  input = jsonencode({
    type = "create-database"
    metadata = {
      databaseName = local.database_name
      owner        = local.username
    }
  })

  depends_on = [data.aws_lambda_invocation.create-user]
}
