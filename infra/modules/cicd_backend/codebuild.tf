resource "aws_codebuild_project" "backend" {
  name          = "${var.name}-backend-build"
  service_role  = aws_iam_role.codebuild.arn
  build_timeout = var.build_timeout_minutes

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    type            = "LINUX_CONTAINER"
    compute_type    = var.build_compute_type
    image           = var.codebuild_image
    privileged_mode = true

    environment_variable {
      name  = "REPOSITORY_URI"
      value = var.ecr_repo_url
    }
    environment_variable {
      name  = "TASK_FAMILY"
      value = var.task_family
    }
    environment_variable {
      name  = "EXEC_ROLE_ARN"
      value = var.task_exec_role_arn
    }

    environment_variable {
      name  = "CONTAINER_NAME"
      value = var.container_name
    }
    environment_variable {
      name  = "CONTAINER_PORT"
      value = tostring(var.container_port)
    }
    environment_variable {
      name  = "CPU"
      value = tostring(var.cpu)
    }
    environment_variable {
      name  = "MEMORY"
      value = tostring(var.memory)
    }

    environment_variable {
      name  = "DB_HOST"
      value = var.db_host
    }
    environment_variable {
      name  = "DB_PORT"
      value = tostring(var.db_port)
    }
    environment_variable {
      name  = "DB_NAME"
      value = var.db_name
    }
    environment_variable {
      name  = "DB_USER"
      value = var.db_user
    }
    environment_variable {
      name  = "DB_PASSWORD"
      value = var.db_password
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/buildspec.yml")
  }

  tags = merge(var.tags, { Name = "${var.name}-backend-build" })
}
