module "appsec_settings" {
  source                                                       = "../modules/org"
  billing_email                                                = var.billing_email
  default_repository_permission                                = "read"
  members_can_create_repositories                              = false
  members_can_create_public_repositories                       = false
  members_can_create_private_repositories                      = false
  members_can_create_internal_repositories                     = false
  members_can_create_pages                                     = false
  dependabot_alerts_enabled_for_new_repositories               = true
  dependency_graph_enabled_for_new_repositories                = true
  secret_scanning_push_protection_enabled_for_new_repositories = true
  secret_scanning_enabled_for_new_repositories                 = true
  dependabot_security_updates_enabled_for_new_repositories     = true
}
