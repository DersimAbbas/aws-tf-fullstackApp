variable "name" {
  description = "Name prefix for CodeDeploy resources."
  type        = string
}

variable "cluster_name" {
  description = "ECS cluster name."
  type        = string
}

variable "service_name" {
  description = "ECS service name."
  type        = string
}

variable "prod_listener_arn" {
  description = "ALB production listener ARN."
  type        = string
}

variable "test_listener_arn" {
  description = "ALB test listener ARN (required for blue/green)."
  type        = string
}

variable "tg_blue_name" {
  description = "Blue target group name."
  type        = string
}

variable "tg_green_name" {
  description = "Green target group name."
  type        = string
}

variable "termination_wait_minutes" {
  description = "Minutes to wait before terminating old (blue) tasks after success."
  type        = number
  default     = 1
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default     = {}
}
