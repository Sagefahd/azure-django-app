variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "West US"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "acr_name" {
  description = "Globally unique ACR name (no hyphens)"
  type        = string
}
