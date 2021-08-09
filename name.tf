resource "random_string" "resource_suffix" {
  length  = 5
  lower   = true
  upper   = false
  number  = false
  special = false
}

locals {
  resource_name = "${data.ns_workspace.this.block_ref}-${random_string.resource_suffix.result}"
  username      = local.resource_name
  database_name = coalesce(var.database_name, data.ns_workspace.this.block_name)
}
