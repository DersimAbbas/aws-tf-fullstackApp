variable "aws_region" {
  type        = string
  description = "AWS region."
  default     = "eu-north-1"
}

variable "project" {
  type        = string
  description = "Project name prefix."
  default     = "demo"
}

variable "app_port" {
  type        = number
  description = "Backend container port."
  default     = 8080
}

variable "db_name" {
  type        = string
  description = "Database name."
  default     = "appdb"
}

variable "db_user" {
  type        = string
  description = "Database master username."
  default     = "appuser"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Database master password."
}

variable "backend_repo_owner" {
  type        = string
  description = "GitHub owner/org for backend repo."
}

variable "backend_repo_name" {
  type        = string
  description = "GitHub backend repo name."
}

variable "backend_repo_branch" {
  type        = string
  description = "Backend repo branch."
  default     = "main"
}

variable "frontend_repo_url" {
  type        = string
  description = "Frontend repo URL (https://github.com/org/repo)."
}

variable "github_token" {
  type        = string
  sensitive   = true
  description = "GitHub PAT used by Amplify (and optionally other integrations)."
}
variable "codestarconnection_arn" {
  type = string
  
}

variable "name" {
  type = string
}

