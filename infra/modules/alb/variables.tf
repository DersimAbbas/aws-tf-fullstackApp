variable "name" {
  description = "Name prefix for ALB resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the ALB."
  type        = list(string)
}

variable "alb_sg_id" {
  description = "Security group ID for the ALB."
  type        = string
}

variable "app_port" {
  description = "Backend service port (target group port)."
  type        = number
}

variable "health_path" {
  description = "Health check path for target groups."
  type        = string
  default     = "/health"
}

variable "prod_listener_port" {
  description = "Production listener port."
  type        = number
  default     = 80
}

variable "enable_test_listener" {
  description = "Enable a test listener for CodeDeploy blue/green."
  type        = bool
  default     = true
}

variable "test_listener_port" {
  description = "Test listener port (used by CodeDeploy blue/green)."
  type        = number
  default     = 9000
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default     = {}
}
