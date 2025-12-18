resource "aws_iam_role" "codepipeline" {
  name = "${var.name}-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "codepipeline.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })

  tags = merge(var.tags, { Name = "${var.name}-codepipeline-role" })
}

data "aws_iam_policy_document" "codepipeline" {
  statement {
    sid    = "ArtifactStoreBucket"
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]
    resources = [aws_s3_bucket.artifacts.arn]
  }

  statement {
    sid    = "ArtifactStoreObjects"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject"
    ]
    resources = ["${aws_s3_bucket.artifacts.arn}/*"]
  }

 statement {
  sid    = "UseConnection"
  effect = "Allow"

  actions = [
    "codestar-connections:UseConnection",
    "codeconnections:UseConnection"
  ]

  resources = [
    local.connection_arn
  ]
}

  statement {
    sid       = "StartBuild"
    effect    = "Allow"
    actions   = ["codebuild:StartBuild", "codebuild:BatchGetBuilds"]
    resources = [aws_codebuild_project.backend.arn]
  }

  statement {
    sid    = "CodeDeployActions"
    effect = "Allow"
    actions = [
      "codedeploy:CreateDeployment",
      "codedeploy:GetDeployment",
      "codedeploy:GetApplication",
      "codedeploy:GetApplicationRevision",
      "codedeploy:RegisterApplicationRevision",
      "codedeploy:GetDeploymentConfig"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "RegisterTaskDef"
    effect    = "Allow"
    actions   = ["ecs:RegisterTaskDefinition"]
    resources = ["*"]
  }

  statement {
    sid       = "PassTaskExecRole"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [var.task_exec_role_arn]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "codepipeline" {
  name   = "${var.name}-codepipeline-policy"
  role   = aws_iam_role.codepipeline.id
  policy = data.aws_iam_policy_document.codepipeline.json
}
