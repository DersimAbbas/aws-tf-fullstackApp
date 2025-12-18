variable "name" {
  description = "Name prefix for ECS resources."
  type        = string
}

variable "subnets_public_ids" {
  description = "Public subnet IDs for ECS tasks (no NAT)."
  type        = list(string)
}

variable "ecs_sg_id" {
  description = "Security group ID for ECS tasks."
  type        = string
}

variable "app_port" {
  description = "Container port for the backend."
  type        = number
}

variable "ecr_image" {
  description = "Full image URI (e.g. <repo_url>:latest)."
  type        = string
}

variable "desired_count" {
  description = "Number of tasks."
  type        = number
  default     = 0
}

variable "cpu" {
  description = "Fargate CPU units."
  type        = number
  default     = 256
}

variable "memory" {
  description = "Fargate memory (MiB)."
  type        = number
  default     = 512
}

variable "assign_public_ip" {
  description = "Assign public IP to tasks (true avoids NAT)."
  type        = bool
  default     = true
}

variable "blue_target_group_arn" {
  description = "ALB target group ARN (blue) used by the ECS service."
  type        = string
}

variable "db_host" {
  type = string
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

variable "db_port" {
  type    = number
  default = 5432
}

variable "container_name" {
  description = "Container name in task definition."
  type        = string
  default     = "backend"
}

variable "health_path" {
  description = "Used only by your app; ALB health check is configured in ALB module."
  type        = string
  default     = "/health"
}

variable "log_retention_days" {
  description = "CloudWatch log retention days (small for cheap demo)."
  type        = number
  default     = 3
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default     = {}
}
