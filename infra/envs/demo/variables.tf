variable "aws_region" { type = string  default = "eu-north-1" }

variable "project"    { type = string  default = "demo" }

# Backend container port
variable "app_port"   { type = number  default = 8080 }

# DB
variable "db_name"    { type = string  default = "appdb" }
variable "db_user"    { type = string  default = "appuser" }
variable "db_password" {
  type      = string
  sensitive = true
}

# Source repos
variable "backend_repo_owner" { type = string }
variable "backend_repo_name"  { type = string }
variable "backend_repo_branch"{ type = string default = "main" }

variable "frontend_repo_url"  { type = string } 
variable "github_token" {
  type      = string
  sensitive = true
}
