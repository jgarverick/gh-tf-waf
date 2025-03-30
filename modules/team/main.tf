# Team module implementing GitHub Well-Architected Framework best practices
# Addresses anti-patterns like over-provisioned access and unclear team structure

resource "github_team" "team" {
  name           = var.name
  description    = var.description
  privacy        = var.privacy
  parent_team_id = var.parent_team_id

  # Create team with default maintainer if specified
  create_default_maintainer = var.create_default_maintainer
}

# Add members to the team
resource "github_team_membership" "members" {
  for_each = toset(var.members)

  team_id  = github_team.team.id
  username = each.key
  role     = "member"
}

# Add maintainers to the team
resource "github_team_membership" "maintainers" {
  for_each = toset(var.maintainers)

  team_id  = github_team.team.id
  username = each.key
  role     = "maintainer"
}

# Add repository permissions for the team
# This follows the principle of least privilege from the Security layer
resource "github_team_repository" "repo_permissions" {
  for_each = var.repository_permissions

  team_id    = github_team.team.id
  repository = each.key
  permission = each.value
}
