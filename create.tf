provider "restapi" {
  uri                  =  local.db_admin_func_url
  write_returns_object = true

  aws_v4_signing {
    service = "lambda"
  }
}

resource "restapi_object" "database_owner" {
  path         = "/roles"
  id_attribute = "name"

  data = jsonencode({
    name        = local.database_name
    useExisting = true
    skipDestroy = true
  })
}

resource "restapi_object" "database" {
  path         = "/databases"
  id_attribute = "name"

  data = jsonencode({
    name        = local.database_name
    owner       = local.database_owner
    useExisting = true
    skipDestroy = true
  })

  depends_on = [restapi_object.database_owner]
}

resource "restapi_object" "role" {
  path         = "/roles"
  id_attribute = "name"

  data = jsonencode({
    name        = local.username
    password    = random_password.this.result
    skipDestroy = true
  })
}

resource "restapi_object" "role_member" {
  path         = "/roles/${local.database_owner}/members/${local.username}"
  id_attribute = "id"

  data = jsonencode({
    member      = local.username
    target      = local.database_owner
    skipDestroy = true
  })

  depends_on = [
    restapi_object.database_owner,
    restapi_object.role
  ]
}

resource "restapi_object" "schema_privileges" {
  path         = "/databases/${local.database_name}/schema_privileges"
  id_attribute = "role"

  data = jsonencode({
    database    = local.database_name
    role        = local.username
    skipDestroy = true
  })

  depends_on = [
    restapi_object.database,
    restapi_object.role
  ]
}

resource "restapi_object" "default_grants" {
  path         = "/roles/${local.username}/default_grants"
  id_attribute = "id"

  data = jsonencode({
    role         = local.username
    target       = local.database_owner
    databaseName = local.database_name
    skipDestroy  = true
  })

  depends_on = [
    restapi_object.role,
    restapi_object.database,
    restapi_object.database_owner
  ]
}
