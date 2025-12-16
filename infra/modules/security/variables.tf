variable "name" {
  description = "Name prefix for all security group resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the security groups will be created."
  type        = string
}

variable "app_port" {
  description = "Backend container/listener port exposed by the service (e.g. 8080)."
  type        = number
}

variable "db_port" {
  description = "Database port (Postgres default 5432)."
  type        = number
  default     = 5432
}

variable "alb_ingress_cidrs" {
  description = "CIDRs allowed to access the ALB listener (HTTP)."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
