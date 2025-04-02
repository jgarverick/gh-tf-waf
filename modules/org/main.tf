
resource "github_organization_settings" "org_settings" {
  billing_email                                                = var.billing_email
  name                                                         = var.organization_name
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
