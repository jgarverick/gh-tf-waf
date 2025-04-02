# GitHub Well-Architected Framework - Governance Pillar

# Organization-wide settings for governance
# Addresses anti-pattern: Uncontrolled repository creation and poor visibility
module "governance_settings" {
  source                                                       = "../modules/org"
  billing_email                                                = var.billing_email
  members_can_create_repositories                              = false
  members_can_create_public_repositories                       = false
  members_can_create_private_repositories                      = false
  members_can_create_internal_repositories                     = true
  dependabot_alerts_enabled_for_new_repositories               = true
  dependabot_security_updates_enabled_for_new_repositories     = true
  dependency_graph_enabled_for_new_repositories                = true
  secret_scanning_enabled_for_new_repositories                 = true
  secret_scanning_push_protection_enabled_for_new_repositories = true
}

# Organization-wide ruleset for branch protection
# Addresses anti-pattern: Inconsistent branch policies and direct pushes to main
module "org_ruleset" {
  source = "../modules/ruleset"

  name        = "WAF Standard Protection"
  target_type = "organization"
  enforcement = "active"

  # Monorepo support: Protect branches that commonly exist in monorepo structures
  protected_branches = ["main", "master", "production", "release/*", "develop"]

  # Operational excellence layer: Standardize code review processes
  rules = {
    creation                  = true
    update                    = true
    deletion                  = true
    required_signatures       = true  # Security: Ensure code integrity
    required_linear_history   = true  # Monorepo: Better history tracking
    required_deployments      = true  # Reliability: Ensure pre-deployment checks
    required_reviewers        = 2     # Quality: Enforce peer reviews
    dismiss_stale_reviews     = true  # Quality: Ensure reviews are current
    require_code_owner_review = true  # Governance: Enforce ownership
    allow_force_pushes        = false # Security: Prevent history rewriting
    allow_deletions           = false # Security: Prevent data loss
  }

  # Allow specific bypass access for administrators
  # Addresses migration scenarios where admin override may be needed
  bypass_actors = [{
    actor_id    = var.admin_team_id
    actor_type  = "Team"
    bypass_mode = "always"
  }]
}

# Default repository settings for standardization
# Addresses anti-pattern: Inconsistent repository configurations
module "default_repo_settings" {
  source            = "../modules/repo"
  organization_name = var.organization_name
  teams             = var.teams
  # Operational excellence layer: Standardize repository settings
  default_repo_config = {
    has_wiki               = false            # Reduce maintenance overhead
    vulnerability_alerts   = true             # Security layer: Enable alerts
    has_projects           = true             # Project management support
    delete_branch_on_merge = true             # Monorepo: Keep branches clean
    has_issues             = true             # Collaboration: Enable tracking
    topics                 = ["waf-governed"] # Discoverability: Tag governed repos
    is_template            = false
    archived               = false
  }

  # Migration support: Apply settings to key repositories
  repositories = [
    {
      name                            = "waf-documentation",
      description                     = "Well-Architected Framework Documentation",
      visibility                      = "internal",
      advanced_security               = true,
      secret_scanning                 = true,
      secret_scanning_push_protection = true
    },
    {
      name                            = "governance-policies",
      description                     = "Corporate governance policies for GitHub",
      visibility                      = "internal",
      advanced_security               = true,
      secret_scanning                 = true,
      secret_scanning_push_protection = true
    }
  ]

  # Security layer: Enforce admin compliance
  enforce_admins = true
}

# Team structure for governance
# Addresses anti-pattern: Unclear permissions and roles
module "governance_team" {
  source = "../modules/team"

  name        = "governance-admins"
  description = "Team responsible for governance policies"
  privacy     = "closed"

  members     = var.governance_team_members
  maintainers = var.governance_team_maintainers

  # Operational excellence layer: Define clear responsibilities
  repository_permissions = {
    "governance-policies" = "admin",
    "waf-documentation"   = "admin",
    "compliance-template" = "admin"
  }

  # Avoid anti-pattern of empty teams
  create_default_maintainer = false
}

# Create security team with appropriate permissions
# Addresses anti-pattern: Missing security oversight
module "security_team" {
  source = "../modules/team"

  name        = "security-admins"
  description = "Team responsible for security policies and reviews"
  privacy     = "closed"

  members     = var.security_team_members
  maintainers = var.security_team_maintainers

  # Security layer: Define security responsibilities
  repository_permissions = {
    "security-policies"   = "admin",
    "compliance-template" = "maintain"
  }
}

# Audit log streaming
# Addresses anti-pattern: Lack of visibility into actions
resource "github_organization_security_manager" "waf_org_security_manager" {
  team_slug = module.governance_team.team_slug
}

# Repository compliance template
# Addresses anti-pattern: Inconsistent repo structures
# Supports migrations by providing a standard starting point
resource "github_repository" "compliance_template" {
  name        = "compliance-template"
  description = "Template repository for compliance settings"
  visibility  = "internal"


  # Monorepo support: Configure branch management
  allow_merge_commit     = false
  allow_squash_merge     = true
  allow_rebase_merge     = true
  delete_branch_on_merge = true

  # Security layer: Enable all security features
  security_and_analysis {
    advanced_security {
      status = "enabled"
    }
    secret_scanning {
      status = "enabled"
    }
    secret_scanning_push_protection {
      status = "enabled"
    }
  }

  # Avoid anti-pattern of empty repos
  auto_init = true
}

# CODEOWNERS file for compliance template
# Addresses anti-pattern: Unclear code ownership
resource "github_repository_file" "compliance_codeowners" {
  repository          = github_repository.compliance_template.name
  branch              = "main"
  file                = ".github/CODEOWNERS"
  content             = <<-EOT
    # Default owners for everything in the repo
    * @${var.organization_name}/governance-admins

    # Security related files
    /.github/workflows/security.yml @${var.organization_name}/security-admins
    /security/ @${var.organization_name}/security-admins
  EOT
  commit_message      = "Add CODEOWNERS file via Terraform"
  commit_author       = "Terraform"
  commit_email        = "terraform@example.com"
  overwrite_on_create = true
}

# GitHub Actions workflow for security scanning
# Addresses anti-pattern: Missing security automation
resource "github_repository_file" "security_workflow" {
  repository          = github_repository.compliance_template.name
  branch              = "main"
  file                = ".github/workflows/security.yml"
  content             = <<-EOT
    name: Security Scanning

    on:
      push:
        branches: [ main ]
      pull_request:
        branches: [ main ]
      schedule:
        - cron: '0 0 * * 0'  # Weekly scan

    jobs:
      scan:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v3
          - name: Run security scan
            uses: github/codeql-action/init@v2
            with:
              languages: javascript, python
          - name: Perform analysis
            uses: github/codeql-action/analyze@v2
  EOT
  commit_message      = "Add security workflow via Terraform"
  commit_author       = "Terraform"
  commit_email        = "terraform@example.com"
  overwrite_on_create = true
}

# Standard README for compliance template
# Addresses anti-pattern: Poor documentation
resource "github_repository_file" "readme" {
  repository          = github_repository.compliance_template.name
  branch              = "main"
  file                = "README.md"
  content             = <<-EOT
    # Compliance Template Repository

    This repository follows the GitHub Well-Architected Framework guidelines.

    ## Security Features

    - Advanced Security: Enabled
    - Secret Scanning: Enabled
    - Push Protection: Enabled

    ## Governance Requirements

    - All changes require pull requests
    - Code owners must approve changes in their areas
    - Branch protection enforces clean history

    ## Getting Started

    Use this repository as a template when creating new projects to ensure
    compliance with organizational standards.
  EOT
  commit_message      = "Add README via Terraform"
  commit_author       = "Terraform"
  commit_email        = "terraform@example.com"
  overwrite_on_create = true
}
