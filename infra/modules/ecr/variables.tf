variable "name" {
  description = "Name prefix for the ECR repository."
  type        = string
}

variable "repository_suffix" {
  description = "Suffix for the repository name."
  type        = string
  default     = "backend"
}

variable "image_tag_mutability" {
  description = "MUTABLE or IMMUTABLE."
  type        = string
  default     = "MUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be MUTABLE or IMMUTABLE."
  }
}

variable "force_delete" {
  description = "If true, deleting the repo will also delete images. Helpful for demos."
  type        = bool
  default     = true
}

variable "enable_lifecycle_policy" {
  description = "If true, adds a lifecycle policy to keep the repo small."
  type        = bool
  default     = true
}

variable "keep_last_images" {
  description = "How many recent images to keep if lifecycle policy is enabled."
  type        = number
  default     = 5
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default     = {}
}
