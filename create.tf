// Create Database will create a database
// Additionally, a role of the same name will be created and given "owner" over database
data "aws_lambda_invocation" "create-database" {
  function_name = local.db_admin_func_name

  input = jsonencode({
    type = "create-database"
    metadata = {
      databaseName = local.database_name
    }
  })
}

data "aws_lambda_invocation" "create-user" {
  function_name = local.db_admin_func_name

  input = jsonencode({
    type = "create-user"
    metadata = {
      username = local.username
      password = random_password.this.result
    }
  })

  depends_on = [data.aws_lambda_invocation.create-database]
}

data "aws_lambda_invocation" "create-db-access" {
  function_name = local.db_admin_func_name

  input = jsonencode({
    type = "create-db-access"
    metadata = {
      databaseName = local.database_name
      username     = local.username
    }
  })

  depends_on = [data.aws_lambda_invocation.create-user]
}
