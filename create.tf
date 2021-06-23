data "aws_lambda_invocation" "create-user" {
  function_name = data.ns_connection.postgres.outputs.lambda_function_name

  input = jsonencode({
    type = "create-user"
    metadata = {
      role_name = local.username
    }
  })
}

locals {
  create_user_result  = jsondecode(data.aws_lambda_invocation.create_user.result)
  password_secret_arn = local.create_user_result["password_secret_arn"]
}

data "aws_lambda_invocation" "create-database" {
  function_name = data.ns_connection.postgres.outputs.lambda_function_name

  input = jsonencode({
    type = "create-database"
    metadata = {
      database_name = var.database_name
      owner         = local.username
    }
  })

  depends_on = [data.aws_lambda_invocation.create_user]
}
