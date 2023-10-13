locals {
  is_v0_7 = local.db_admin_version == "0.7"
}

resource "aws_lambda_invocation" "database_owner" {
  count = local.is_v0_7 ? 1 : 0

  function_name   = local.db_admin_func_name
  lifecycle_scope = "CRUD"

  input = jsonencode({
    type = "roles"
    data = {
      name        = local.database_name
      useExisting = true
    }
  })
}

resource "aws_lambda_invocation" "database" {
  count = local.is_v0_7 ? 1 : 0

  function_name   = local.db_admin_func_name
  lifecycle_scope = "CRUD"

  input = jsonencode({
    type = "databases"
    data = {
      name        = local.database_name
      owner       = local.database_owner
      useExisting = true
    }
  })

  depends_on = [aws_lambda_invocation.database_owner]
}

resource "aws_lambda_invocation" "role" {
  count = local.is_v0_7 ? 1 : 0

  function_name   = local.db_admin_func_name
  lifecycle_scope = "CRUD"

  input = jsonencode({
    type = "roles"
    data = {
      name        = local.username
      password    = random_password.this.result
      useExisting = true
    }
  })
}

resource "aws_lambda_invocation" "role_member" {
  count = local.is_v0_7 ? 1 : 0

  function_name   = local.db_admin_func_name
  lifecycle_scope = "CRUD"

  input = jsonencode({
    type = "role_members"
    data = {
      target      = local.database_owner
      member      = local.username
      useExisting = true
    }
  })

  depends_on = [
    aws_lambda_invocation.database_owner,
    aws_lambda_invocation.role
  ]
}

resource "aws_lambda_invocation" "schema_privileges" {
  count = local.is_v0_7 ? 1 : 0

  function_name   = local.db_admin_func_name
  lifecycle_scope = "CRUD"

  input = jsonencode({
    type = "schema_privileges"
    data = {
      database = local.database_name
      role     = local.username
    }
  })

  depends_on = [
    aws_lambda_invocation.database,
    aws_lambda_invocation.role
  ]
}

resource "aws_lambda_invocation" "default_grants" {
  count = local.is_v0_7 ? 1 : 0

  function_name   = local.db_admin_func_name
  lifecycle_scope = "CRUD"

  input = jsonencode({
    type = "default_grants"
    data = {
      role     = local.username
      target   = local.database_owner
      database = local.database_name
    }
  })

  depends_on = [
    aws_lambda_invocation.role,
    aws_lambda_invocation.database,
    aws_lambda_invocation.database_owner
  ]
}
