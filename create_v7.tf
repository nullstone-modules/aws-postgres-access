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

// Re-verifies the role's password on every plan; pg-db-admin alters it only when a login attempt fails.
// This heals a role created passwordless (e.g. by postgres-restore-access) or reset outside this
// workspace -- the `role` invocation above only fires when its input changes, so it cannot.
// A missing role fails the plan loudly; creating the role stays the job of the `role` invocation.
data "aws_lambda_invocation" "ensure_role_password" {
  count = local.is_v0_7 && local.db_admin_ensure_password ? 1 : 0

  function_name = local.db_admin_func_name

  input = jsonencode({
    type = "ensure_role_password"
    data = {
      name     = local.username
      password = random_password.this.result
    }
  })

  depends_on = [aws_lambda_invocation.role]
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
