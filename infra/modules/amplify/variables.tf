variable "name" {
  type        = string
  description = "Name prefix for Amplify resources."
}

variable "repo_url" {
  type        = string
  description = "Frontend repository URL (e.g. https://github.com/org/repo)."
}

variable "github_token" {
  type        = string
  sensitive   = true
  description = "GitHub PAT used by Amplify to access the repo."
}

variable "branch" {
  type        = string
  default     = "main"
  description = "Git branch to build/deploy."
}

variable "app_environment_variables" {
  type = map(string)
  default = {
    REACT_APP_API_URL = "https://example.com"
  }
  description = "Environment variables for the Amplify app."
}

variable "enable_auto_build" {
  type        = bool
  default     = true
  description = "Automatically build/deploy on git push."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to resources."
}
