# GitHub Well-Architected Framework - Architecture Pillar

# Define local variables for common configurations
locals {
  # Define repository names for architecture components
  architecture_repositories = [
    "api-gateway",
    "authentication-service",
    "user-management-service",
    "data-pipeline",
    "reporting-service"
  ]

  # Define team names for architecture ownership
  architecture_teams = {
    api_gateway       = "api-gateway-team"
    authentication    = "authentication-team"
    user_management   = "user-management-team"
    data_pipeline     = "data-engineering-team"
    reporting         = "reporting-team"
    shared_components = "platform-engineering-team"
  }

  # Define branch protection rules for architecture repositories
  branch_protection_rules = {
    "main" = {
      required_pull_request_reviews = {
        required_approving_review_count = 2
        dismiss_stale_reviews           = true
        require_code_owner_review       = true
      }
      required_status_checks = {
        strict   = true
        contexts = ["ci/build", "ci/test"]
      }
      enforce_admins = true
    }
  }
}

# Create repositories for each architecture component
# Addresses anti-pattern: Monolithic architecture
resource "github_repository" "architecture_components" {
  for_each = toset(local.architecture_repositories)

  name        = each.value
  description = "Repository for ${each.value} component"
  visibility  = "private"

  # Enable security features by default
  vulnerability_alerts = true
  has_issues           = true
  has_projects         = true
  has_wiki             = false

  # Monorepo support: Ensure consistent naming conventions
  topics = ["waf-architecture", "monorepo-component"]

  # Migration support: Enable squash merging for cleaner history
  allow_squash_merge     = true
  allow_merge_commit     = false
  delete_branch_on_merge = true
}

# Create teams for each architecture component
# Addresses anti-pattern: Lack of clear ownership
module "architecture_teams" {
  for_each = local.architecture_teams

  source = "../modules/team"

  name        = each.key
  description = "Team responsible for ${each.key} component"
  privacy     = "closed"

  # Define team members and maintainers (replace with actual values)
  members     = var.team_members[each.key]
  maintainers = var.team_maintainers[each.key]

  # Grant appropriate permissions to repositories
  repository_permissions = {
    github_repository.architecture_components[each.key].name = "admin"
  }
}

# Apply branch protection rules to architecture repositories
# Addresses anti-pattern: Unprotected branches
resource "github_branch_protection" "architecture_branch_protection" {
  pattern = "main"

  for_each = github_repository.architecture_components

  repository_id = each.value.node_id

  # Enforce required pull request reviews
  required_pull_request_reviews {
    required_approving_review_count = 2
    dismiss_stale_reviews           = true
  }

  # Enforce required status checks
  required_status_checks {
    strict   = true
    contexts = ["ci/build", "ci/test"]
  }

  # Enforce admin status
  enforce_admins = true
}

# Define GitHub Actions workflows for CI/CD
# Addresses anti-pattern: Manual deployments
resource "github_repository_file" "ci_cd_workflow" {
  for_each            = github_repository.architecture_components
  repository          = each.value.name
  branch              = "main"
  file                = "../templates/workflows/ci-cd.yml"
  content             = file("../templates/workflows/ci-cd.yml")
  commit_message      = "Add CI/CD workflow via Terraform"
  commit_author       = "GitHub WAF"
  commit_email        = "waf@example.com"
  overwrite_on_create = true
}

# Define issue labels for architecture-related issues
# Addresses anti-pattern: Inconsistent issue tracking
resource "github_issue_labels" "architecture_labels" {
  repository = github_repository.architecture_components[0].name
  for_each = {
    "architecture:design"      = "0052CC" # Blue
    "architecture:refactor"    = "CC0000" # Red
    "architecture:performance" = "CC6600" # Orange
    "architecture:security"    = "CC00CC" # Purple
  }
  label {
    name        = each.key
    color       = each.value
    description = "Architecture-related issue"
  }

}

# Define variables for team members and maintainers
variable "team_members" {
  type = map(list(string))
  default = {
    api_gateway       = ["alice", "bob"]
    authentication    = ["charlie", "dave"]
    user_management   = ["eve", "frank"]
    data_pipeline     = ["grace", "heidi"]
    reporting         = ["ivan", "judy"]
    shared_components = ["mallory", "oscar"]
  }
  description = "Map of team names to list of team members"
}

variable "team_maintainers" {
  type = map(list(string))
  default = {
    api_gateway       = ["alice"]
    authentication    = ["charlie"]
    user_management   = ["eve"]
    data_pipeline     = ["grace"]
    reporting         = ["ivan"]
    shared_components = ["mallory"]
  }
  description = "Map of team names to list of team maintainers"
}
