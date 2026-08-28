variable "app_metadata" {
  description = <<EOF
Nullstone automatically injects metadata from the app module into this module through this variable.
This variable is a reserved variable for capabilities.
EOF

  type    = map(string)
  default = {}
}

locals {
  security_group_id = var.app_metadata["security_group_id"]
}

variable "database_name" {
  type        = string
  description = <<EOF
Name of database to create in Postgres cluster. If left blank, uses app name.
The following identifiers are supported for interpolation:
  {{ NULLSTONE_STACK }}
  {{ NULLSTONE_BLOCK }}
  {{ NULLSTONE_APP }}
  {{ NULLSTONE_ENV }}
EOF
  default     = ""
}

variable "username" {
  type        = string
  default     = ""
  description = <<EOF
Override the name of the Postgres role created for this app.
If left blank, a unique role name is generated. (Recommended)
The following identifiers are supported for interpolation:
  {{ NULLSTONE_STACK }}
  {{ NULLSTONE_BLOCK }}
  {{ NULLSTONE_APP }}
  {{ NULLSTONE_ENV }}
Warning: If two apps use the same role name, each app resets the role's password when it launches/updates,
invalidating the other app's credentials and breaking its database access.
EOF
}

// We are using ns_env_variables to interpolate database_name and username.
// NULLSTONE_APP is a legacy alias for NULLSTONE_BLOCK.
data "ns_env_variables" "names" {
  input_env_variables = tomap({
    NULLSTONE_STACK = local.stack_name
    NULLSTONE_BLOCK = local.block_name
    NULLSTONE_APP   = local.block_name
    NULLSTONE_ENV   = local.env_name
    DATABASE_NAME   = coalesce(var.database_name, local.block_name)
    USERNAME        = var.username
  })
  input_secrets = tomap({})
}

locals {
  // Interpolate var.username, not local.username, so the generated fallback stays out of the data source
  // input. resource_name depends on random_string, which is unknown until the first apply.
  username       = coalesce(data.ns_env_variables.names.env_variables["USERNAME"], local.resource_name)
  database_name  = data.ns_env_variables.names.env_variables["DATABASE_NAME"]
  database_owner = local.database_name
}
