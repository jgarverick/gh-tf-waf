# Repository module implementing GitHub Well-Architected Framework best practices
# Addresses anti-patterns like inconsistent configuration and security gaps

# Default repository settings resource
resource "github_organization_settings" "default_repo_settings" {
  # Apply best practices for repository defaults (eliminates anti-pattern of inconsistent settings)
  billing_email                            = var.billing_email
  members_can_create_repositories          = false # Prevent uncontrolled repository creation
  members_can_create_internal_repositories = true  # Allow internal sharing but with governance
  members_can_create_pages                 = false # Prevent uncontrolled pages creation
  members_can_create_public_repositories   = false # Prevent unintentional public exposure
  members_can_fork_private_repositories    = false # Prevent IP leakage through forks

  # Security settings aligned with the Security layer of WAF
  web_commit_signoff_required                              = true # Ensure all commits are verified
  dependabot_alerts_enabled_for_new_repositories           = true # Auto-enable vulnerability detection
  dependabot_security_updates_enabled_for_new_repositories = true # Auto-remediation
  dependency_graph_enabled_for_new_repositories            = true # Enable dependency analysis

  # Advanced security features
  advanced_security_enabled_for_new_repositories               = true # GitHub Advanced Security
  secret_scanning_enabled_for_new_repositories                 = true # Detect leaked secrets
  secret_scanning_push_protection_enabled_for_new_repositories = true # Prevent secret leaks

  depends_on = [github_repository.repositories]
}

# Repository resources for each repository in the variable
resource "github_repository" "repositories" {
  for_each = { for repo in var.repositories : repo.name => repo }

  name         = each.value.name
  description  = each.value.description
  homepage_url = each.value.homepage_url
  visibility   = each.value.visibility

  # Apply defaults from default_repo_config if not specified
  has_wiki               = each.value.has_wiki != null ? each.value.has_wiki : var.default_repo_config.has_wiki
  vulnerability_alerts   = each.value.vulnerability_alerts != null ? each.value.vulnerability_alerts : var.default_repo_config.vulnerability_alerts
  has_projects           = each.value.has_projects != null ? each.value.has_projects : var.default_repo_config.has_projects
  delete_branch_on_merge = each.value.delete_branch_on_merge != null ? each.value.delete_branch_on_merge : var.default_repo_config.delete_branch_on_merge
  has_issues             = each.value.has_issues != null ? each.value.has_issues : var.default_repo_config.has_issues
  is_template            = each.value.is_template != null ? each.value.is_template : var.default_repo_config.is_template
  archived               = each.value.archived != null ? each.value.archived : var.default_repo_config.archived
  topics                 = each.value.topics != null ? each.value.topics : var.default_repo_config.topics

  # Apply template configuration if specified
  dynamic "template" {
    for_each = each.value.template != null ? [each.value.template] : []
    content {
      owner                = template.value.owner
      repository           = template.value.repository
      include_all_branches = template.value.include_all_branches
    }
  }

  # Apply security and analysis settings if specified
  # This addresses the "Security" layer of the Well-Architected Framework
  dynamic "security_and_analysis" {
    for_each = each.value.advanced_security != null || each.value.secret_scanning != null ? [1] : []
    content {
      dynamic "advanced_security" {
        for_each = each.value.advanced_security != null && each.value.advanced_security ? [1] : []
        content {
          status = "enabled"
        }
      }
      dynamic "secret_scanning" {
        for_each = each.value.secret_scanning != null && each.value.secret_scanning ? [1] : []
        content {
          status = "enabled"
        }
      }
      dynamic "secret_scanning_push_protection" {
        for_each = each.value.secret_scanning_push_protection != null && each.value.secret_scanning_push_protection ? [1] : []
        content {
          status = "enabled"
        }
      }
    }
  }

  # Monorepo support - Auto-initializes with a README for better discoverability
  auto_init = true

  # Optimized for migrations - set proper merge options
  allow_merge_commit = false # Prefer rebase over merge commits for cleaner history
  allow_rebase_merge = true
  allow_squash_merge = true # Support for feature branches being squashed

  # Avoid code review anti-pattern of direct pushes to protected branches
  allow_update_branch = true # Enable "Update branch" button for PRs
}

# Automated CODEOWNERS file for all repositories
# Addresses the anti-pattern of unclear code ownership
resource "github_repository_file" "codeowners" {
  for_each = { for repo in var.repositories : repo.name => repo }

  repository          = each.value.name
  branch              = "main"
  file                = "CODEOWNERS"
  content             = "# Default owners for everything in the repo\n* @${github_repository.repositories[each.key].name}-admins\n"
  commit_message      = "Add CODEOWNERS file via Terraform"
  commit_author       = "Terraform"
  commit_email        = "terraform@example.com"
  overwrite_on_create = true

  depends_on = [github_repository.repositories]
}
