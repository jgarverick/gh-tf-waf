# Module for organization-wide settings

variable "billing_email" {
  description = "Billing email for the organization"
  type        = string
  default     = "test@example.org"
}

variable "organization_name" {
  description = "Name of the GitHub organization"
  type        = string
  default     = "example-org"
}

variable "members_can_create_repositories" {
  description = "Whether members can create repositories"
  type        = bool
  default     = false
}

variable "members_can_create_public_repositories" {
  description = "Whether members can create public repositories"
  type        = bool
  default     = false
}

variable "members_can_create_private_repositories" {
  description = "Whether members can create private repositories"
  type        = bool
  default     = false
}

variable "members_can_create_internal_repositories" {
  description = "Whether members can create internal repositories"
  type        = bool
  default     = false
}

variable "dependabot_alerts_enabled_for_new_repositories" {
  description = "Enable Dependabot alerts for new repositories"
  type        = bool
  default     = false
}

variable "dependabot_security_updates_enabled_for_new_repositories" {
  description = "Enable Dependabot security updates for new repositories"
  type        = bool
  default     = false
}

variable "dependency_graph_enabled_for_new_repositories" {
  description = "Enable dependency graph for new repositories"
  type        = bool
  default     = false
}

variable "secret_scanning_enabled_for_new_repositories" {
  description = "Enable secret scanning for new repositories"
  type        = bool
  default     = false
}

variable "secret_scanning_push_protection_enabled_for_new_repositories" {
  description = "Enable secret scanning push protection for new repositories"
  type        = bool
  default     = false
}

variable "default_repository_permission" {
  description = "Default permission for repositories in the organization"
  type        = string
  default     = "read"
  validation {
    condition     = contains(["read", "write", "admin", "none"], var.default_repository_permission)
    error_message = "Valid values for default_repository_permission are 'read', 'write', 'admin', or 'none'."
  }
}

variable "members_can_create_pages" {
  description = "Whether members can create GitHub Pages"
  type        = bool
  default     = false
}
