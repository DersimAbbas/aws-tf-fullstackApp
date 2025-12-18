output "artifact_bucket_name" {
  value = aws_s3_bucket.artifacts.bucket
}

output "pipeline_name" {
  value = aws_codepipeline.backend.name
}

output "codebuild_project_name" {
  value = aws_codebuild_project.backend.name
}

output "codestar_connection_arn" {
  value = local.connection_arn
}
