data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  connection_name      = coalesce(var.codestar_connection_name, "${var.name}-github-conn")
  connection_arn       = var.create_codestar_connection ? aws_codestarconnections_connection.this[0].arn : var.codestar_connection_arn
  artifact_bucket_name = lower(replace("${var.name}-artifacts-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.id}", "_", "-"))
}
