resource "aws_amplify_app" "this" {
  name        = "${var.name}-frontend"
  repository  = var.repo_url
  oauth_token = var.github_token

  build_spec = file("${path.module}/buildspec.yml")

  environment_variables = var.app_environment_variables

  tags = merge(var.tags, {
    Name = "${var.name}-frontend"
  })
}

resource "aws_amplify_branch" "this" {
  app_id            = aws_amplify_app.this.id
  branch_name       = var.branch
  enable_auto_build = var.enable_auto_build

  tags = merge(var.tags, {
    Name = "${var.name}-frontend-${var.branch}"
  })
}
