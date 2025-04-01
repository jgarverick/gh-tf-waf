# Module for organization-wide settings

variable "billing_email" {
  description = "Billing email for the organization"
  type        = string
}

variable "members_can_create_repositories" {
  description = "Whether members can create repositories"
  type        = bool
}

variable "members_can_create_public_repositories" {
  description = "Whether members can create public repositories"
  type        = bool
}

variable "members_can_create_private_repositories" {
  description = "Whether members can create private repositories"
  type        = bool
}

variable "members_can_create_internal_repositories" {
  description = "Whether members can create internal repositories"
  type        = bool
}

variable "dependabot_alerts_enabled_for_new_repositories" {
  description = "Enable Dependabot alerts for new repositories"
  type        = bool
}

variable "dependabot_security_updates_enabled_for_new_repositories" {
  description = "Enable Dependabot security updates for new repositories"
  type        = bool
}

variable "dependency_graph_enabled_for_new_repositories" {
  description = "Enable dependency graph for new repositories"
  type        = bool
}

variable "secret_scanning_enabled_for_new_repositories" {
  description = "Enable secret scanning for new repositories"
  type        = bool
}

variable "secret_scanning_push_protection_enabled_for_new_repositories" {
  description = "Enable secret scanning push protection for new repositories"
  type        = bool
}

variable "default_repository_permission" {
  description = "Default permission for repositories in the organization"
  type        = string
  default     = "read"
}

variable "members_can_create_pages" {
  description = "Whether members can create GitHub Pages"
  type        = bool
  default     = false
}

resource "github_organization_settings" "org_settings" {
  billing_email = var.billing_email

  members_can_create_repositories                              = var.members_can_create_repositories
  members_can_create_public_repositories                       = var.members_can_create_public_repositories
  members_can_create_private_repositories                      = var.members_can_create_private_repositories
  members_can_create_internal_repositories                     = var.members_can_create_internal_repositories
  members_can_create_pages                                     = var.members_can_create_pages
  dependabot_alerts_enabled_for_new_repositories               = var.dependabot_alerts_enabled_for_new_repositories
  dependabot_security_updates_enabled_for_new_repositories     = var.dependabot_security_updates_enabled_for_new_repositories
  dependency_graph_enabled_for_new_repositories                = var.dependency_graph_enabled_for_new_repositories
  secret_scanning_enabled_for_new_repositories                 = var.secret_scanning_enabled_for_new_repositories
  secret_scanning_push_protection_enabled_for_new_repositories = var.secret_scanning_push_protection_enabled_for_new_repositories
  default_repository_permission                                = var.default_repository_permission
}
