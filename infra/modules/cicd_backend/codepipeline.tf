resource "aws_codepipeline" "backend" {
  name     = "${var.name}-backend-pipeline"
  role_arn = aws_iam_role.codepipeline.arn
  pipeline_type = "V2"
  execution_mode = "QUEUED"

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
  }

  trigger {
    provider_type = "CodeStarSourceConnection"
    git_configuration {
      source_action_name = "Source"

      push {
        branches {
          includes = [var.github_branch]
        }
      }
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        ConnectionArn    = local.connection_arn
        FullRepositoryId = var.github_repo_full_name
        BranchName = var.github_branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Docker_Build_Push"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]

      configuration = {
        ProjectName = aws_codebuild_project.backend.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "ECS_BlueGreen_Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      version         = "1"
      input_artifacts = ["BuildArtifact"]

      configuration = {
        ApplicationName     = var.codedeploy_app_name
        DeploymentGroupName = var.codedeploy_deployment_group_name

        TaskDefinitionTemplateArtifact = "BuildArtifact"
        TaskDefinitionTemplatePath     = "taskdef.json"

        AppSpecTemplateArtifact = "BuildArtifact"
        AppSpecTemplatePath     = "appspec.yaml"

        Image1ArtifactName  = "BuildArtifact"
        Image1ContainerName = "IMAGE1_NAME"
      }
    }
  }

  tags = merge(var.tags, { Name = "${var.name}-backend-pipeline" })

  depends_on = [
    aws_iam_role_policy.codepipeline
  ]
}
