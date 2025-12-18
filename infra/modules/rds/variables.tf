variable "name" {
  description = "Name prefix for all RDS resources."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the DB subnet group (at least 2 recommended)."
  type        = list(string)
}

variable "rds_sg_id" {
  description = "Security group ID for the DB instance."
  type        = string
}

variable "engine" {
  description = "Database engine."
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Database engine version."
  type        = string
  default     = "16"
}

variable "instance_class" {
  description = "RDS instance type (cheap default)."
  type        = string
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  description = "Storage in GB."
  type        = number
  default     = 20
}

variable "storage_type" {
  description = "Storage type."
  type        = string
  default     = "gp2"
}

variable "db_name" {
  description = "Initial database name."
  type        = string
}

variable "db_user" {
  description = "Master username."
  type        = string
}

variable "db_password" {
  description = "Master password."
  type        = string
  sensitive   = true
}

variable "port" {
  description = "DB port (Postgres default 5432)."
  type        = number
  default     = 5432
}

variable "multi_az" {
  description = "Multi-AZ costs more; keep false for cheapest."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Keep small for short-lived demo."
  type        = number
  default     = 0
}

variable "deletion_protection" {
  description = "Disable for demo so destroy works."
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip snapshot for quick teardown."
  type        = bool
  default     = true
}

variable "publicly_accessible" {
  description = "Must be false for private DB."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
