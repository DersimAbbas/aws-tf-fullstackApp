variable "name" {
  type        = string
  description = "Name prefix for pipeline resources."
}

variable "tags" {
  type    = map(string)
  default = {}
}

# GitHub source (CodeStar connection)
variable "github_repo_full_name" {
  type        = string
  description = "GitHub repo in the form owner/repo (FullRepositoryId)."
}

variable "github_branch" {
  type    = string
  default = "main"
}

variable "create_codestar_connection" {
  type        = bool
  default     = true
  description = "If true, create a new CodeStar connection (requires console confirmation)."
}

variable "codestar_connection_arn" {
  type        = string
  default     = null
  description = "Existing CodeStar connection ARN. Required if create_codestar_connection=false."
}

variable "codestar_connection_name" {
  type        = string
  default     = null
  description = "Name for created connection (only used if create_codestar_connection=true)."
}

# ECR
variable "ecr_repo_url" {
  type        = string
  description = "ECR repository URL, e.g. <acct>.dkr.ecr.<region>.amazonaws.com/<repo>"
}

# CodeDeploy (from your codedeploy module outputs)
variable "codedeploy_app_name" {
  type        = string
  description = "CodeDeploy application name (ECS compute platform)."
}

variable "codedeploy_deployment_group_name" {
  type        = string
  description = "CodeDeploy deployment group name."
}

# ECS task definition template fields (for generated taskdef.json)
variable "task_family" {
  type        = string
  description = "ECS task definition family name."
}

variable "task_exec_role_arn" {
  type        = string
  description = "ECS task execution role ARN."
}

variable "container_name" {
  type    = string
  default = "backend"
}

variable "container_port" {
  type        = number
  description = "Container port exposed by the backend."
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

# App runtime env (so the generated taskdef includes DB settings)
variable "db_host" {
  type = string
}
variable "db_port" {
  type    = number
  default = 5432
}
variable "db_name" {
  type = string
}
variable "db_user" {
  type = string
}
variable "db_password" {
  type      = string
  sensitive = true
}

# CodeBuild
variable "codebuild_image" {
  type        = string
  default     = "aws/codebuild/standard:7.0"
  description = "CodeBuild environment image."
}

variable "build_compute_type" {
  type    = string
  default = "BUILD_GENERAL1_SMALL"
}

variable "build_timeout_minutes" {
  type    = number
  default = 20
}

# Artifact bucket
variable "artifact_bucket_force_destroy" {
  type    = bool
  default = true
}
