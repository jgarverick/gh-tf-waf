# GitHub Well-Architected Framework - Architecture Pillar

# Define local variables for common configurations
locals {
  # Update architecture_repositories to include objects with attributes
  architecture_repositories = [
    { name = "api_gateway", team = "api-gateway-team" },
    { name = "authentication_service", team = "authentication-team" },
    { name = "user_management_service", team = "user-management-team" },
    { name = "data_pipeline", team = "data-engineering-team" },
    { name = "reporting_service", team = "reporting-team" }
  ]

  # Define team names for architecture ownership
  architecture_teams = {
    api_gateway             = "api-gateway-team"
    authentication_service  = "authentication-team"
    user_management_service = "user-management-team"
    data_pipeline           = "data-engineering-team"
    reporting_service       = "reporting-team"
    shared_components       = "platform-engineering-team"
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

# Refactor to use for_each for dynamic module creation

module "architecture_repositories" {
  for_each = { for repo in local.architecture_repositories : repo.name => repo }

  source            = "../modules/repo"
  organization_name = var.organization_name
  repositories = [
    {
      name        = each.value.name
      description = "Repository for ${each.value.name}"
      visibility  = "private"
    }
  ]
  teams = [
    {
      name       = each.value.team
      permission = "admin"
    }
  ]
}

module "architecture_teams" {
  for_each = tomap(local.architecture_teams)

  source = "../modules/team"
  name   = each.key

  members     = var.team_members[each.key]
  maintainers = var.team_maintainers[each.key]
  repository_permissions = {
    (each.key) = "admin"
  }
}

module "architecture_branch_protection" {
  for_each = { for repo in local.architecture_repositories : repo.name => repo }

  source              = "../modules/ruleset"
  target_repositories = [each.value.name]
  rules               = local.branch_protection_rules
  depends_on          = [module.architecture_repositories]
}

module "ci_cd_workflows" {
  for_each = { for repo in local.architecture_repositories : repo.name => repo }

  source             = "../modules/action"
  workflow_file      = "ci-cd.yml"
  repository         = each.value.name
  workflow_file_path = "../templates/workflows/ci-cd.yml"
}

module "architecture_labels" {
  for_each = { for repo in local.architecture_repositories : repo.name => repo }

  source     = "../modules/labels"
  repository = each.value.name
  labels = {
    "architecture:design"      = "0052CC"
    "architecture:refactor"    = "CC0000"
    "architecture:performance" = "CC6600"
    "architecture:security"    = "CC00CC"
  }
}
