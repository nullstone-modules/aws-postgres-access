provider "restapi" {
  uri                  =  local.db_admin_func_url
  write_returns_object = true

  aws_v4_signing {
    service = "lambda-url"
  }
}

// Create Database will create a database
// Additionally, a role of the same name will be created and given "owner" over database
resource "restapi_object" "database" {
  path         = "/databases"
  id_attribute = "name"

  data = jsonencode({
    name = local.database_name
  })
}

resource "restapi_object" "user" {
  path         = "/users"
  id_attribute = "name"

  data = jsonencode({
    name     = local.username
    password = random_password.this.result
  })
}

resource "restapi_object" "user_access" {
  path = "/user_access"

  data = jsonencode({
    databaseName = local.database_name
    username     = local.username
  })

  depends_on = [
    restapi_object.database,
    restapi_object.user
  ]
}
