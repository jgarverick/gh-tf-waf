# Example: Organization-level configuration

# Enable organization-wide settings (example)
resource "github_organization_settings" "org_settings" {
  billing_email                                                = var.billing_email
  default_repository_permission                                = "read"
  dependabot_alerts_enabled_for_new_repositories               = true
  secret_scanning_push_protection_enabled_for_new_repositories = true
}

# Create teams (example)
resource "github_team" "admin_team" {
  name        = "admins"
  description = "Team for administrators"
  privacy     = "closed"
}

resource "github_team" "developers_team" {
  name        = "developers"
  description = "Team for developers"
  privacy     = "closed"
}

# Add members to teams (example)
resource "github_team_membership" "admin_membership" {
  team_id  = github_team.admin_team.id
  username = "your-github-username" # Replace with the GitHub username
  role     = "maintainer"
}

resource "github_team_membership" "developer_membership" {
  team_id  = github_team.developers_team.id
  username = "another-github-username" # Replace with another GitHub username
  role     = "member"
}
