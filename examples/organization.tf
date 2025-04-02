# Example: Organization-level configuration

# Enable organization-wide settings (example)
module "org_settings" {
  source = "../modules/org"

  billing_email                                                = var.billing_email
  default_repository_permission                                = "read"
  dependabot_alerts_enabled_for_new_repositories               = true
  secret_scanning_push_protection_enabled_for_new_repositories = true
}

# Create teams (example)
module "admin_team" {
  source      = "../modules/team"
  name        = "admins"
  description = "Team for administrators"
  privacy     = "closed"
}

module "developers_team" {
  source      = "../modules/team"
  name        = "developers"
  description = "Team for developers"
  privacy     = "closed"
}
