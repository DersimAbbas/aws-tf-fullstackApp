resource "aws_codestarconnections_connection" "this" {
  count         = var.create_codestar_connection ? 1 : 0
  name          = local.connection_name
  provider_type = "GitHub"

  tags = merge(var.tags, { Name = local.connection_name })
}
