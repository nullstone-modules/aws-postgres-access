data "ns_connection" "postgres" {
  name     = "postgres"
  type     = "postgres/aws"
  contract = "datastore/aws/postgres:*"
}

locals {
  db_endpoint          = data.ns_connection.postgres.outputs.db_endpoint
  db_subdomain         = split(":", local.db_endpoint)[0]
  db_port              = split(":", local.db_endpoint)[1]
  db_security_group_id = data.ns_connection.postgres.outputs.db_security_group_id
}

data "aws_lambda_function_url" "db_admin" {
  function_name = local.db_admin_func_name
}

locals {
  db_admin_func_name = data.ns_connection.postgres.outputs.db_admin_function_name
  db_admin_func_url  = data.aws_lambda_function_url.db_admin.function_url
  db_admin_invoker   = data.ns_connection.postgres.outputs.db_admin_invoker
}
