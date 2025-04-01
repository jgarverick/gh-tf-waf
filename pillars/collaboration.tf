# GitHub Well-Architected Framework - Collaboration Pillar

locals {
  # Define file paths for templates - centralized management
  template_files = {
    bug_report         = "${path.module}/../templates/bug_report.md"
    feature_request    = "${path.module}/../templates/feature_request.md"
    monorepo_change    = "${path.module}/../templates/monorepo_change.md"
    pr_template        = "${path.module}/../templates/pull_request_template.md"
    discussion_config  = "${path.module}/../templates/discussion_categories.yml"
    issue_automation   = "${path.module}/../templates/workflows/issue_automation.yml"
    project_automation = "${path.module}/../templates/workflows/project_automation.yml"
    stale_issues       = "${path.module}/../templates/workflows/stale_issues.yml"
    cross_repo         = "${path.module}/../templates/workflows/cross_repo_visibility.yml"
    team_meeting       = "${path.module}/../templates/meeting_template.md"
    release_template   = "${path.module}/../templates/release_template.md"
  }
}

# Issue templates for standardized communication
# Addresses anti-pattern: Inconsistent issue reporting and poor project visibility
resource "github_repository_file" "bug_report_template" {
  repository          = "compliance-template"
  branch              = "main"
  file                = ".github/ISSUE_TEMPLATE/bug_report.md"
  content             = file(local.template_files.bug_report)
  commit_message      = "Add bug report template via Terraform"
  commit_author       = "GitHub WAF"
  commit_email        = "waf@example.com"
  overwrite_on_create = true
}

resource "github_repository_file" "feature_request_template" {
  repository          = "compliance-template"
  branch              = "main"
  file                = ".github/ISSUE_TEMPLATE/feature_request.md"
  content             = file(local.template_files.feature_request)
  commit_message      = "Add feature request template via Terraform"
  commit_author       = "GitHub WAF"
  commit_email        = "waf@example.com"
  overwrite_on_create = true
}

# Special template for monorepo changes
# Addresses anti-pattern: Missing context for cross-component changes
resource "github_repository_file" "monorepo_change_template" {
  repository          = "compliance-template"
  branch              = "main"
  file                = ".github/ISSUE_TEMPLATE/monorepo_change.md"
  content             = file(local.template_files.monorepo_change)
  commit_message      = "Add monorepo cross-component change template via Terraform"
  commit_author       = "GitHub WAF"
  commit_email        = "waf@example.com"
  overwrite_on_create = true
}

# PR templates to standardize code reviews
# Addresses anti-pattern: Inconsistent PR quality and process
resource "github_repository_file" "pr_template" {
  repository          = "compliance-template"
  branch              = "main"
  file                = ".github/PULL_REQUEST_TEMPLATE.md"
  content             = file(local.template_files.pr_template)
  commit_message      = "Add PR template via Terraform"
  commit_author       = "GitHub WAF"
  commit_email        = "waf@example.com"
  overwrite_on_create = true
}

# Discussion categories to organize team communication
# Addresses anti-pattern: Scattered communication and tribal knowledge
resource "github_repository_file" "discussion_categories" {
  repository          = "compliance-template"
  branch              = "main"
  file                = ".github/discussion-categories.yml"
  content             = file(local.template_files.discussion_config)
  commit_message      = "Add discussion categories configuration via Terraform"
  commit_author       = "GitHub WAF"
  commit_email        = "waf@example.com"
  overwrite_on_create = true
}

# Cross-repository labels for consistent tagging
# Addresses anti-pattern: Inconsistent labeling across repositories
resource "github_issue_labels" "priority_labels" {
  repository = "compliance-template"
  for_each = {
    "priority:critical" = "FF0000" # Red
    "priority:high"     = "FFA500" # Orange
    "priority:medium"   = "FFFF00" # Yellow
    "priority:low"      = "00FF00" # Green
  }
  label {
    name        = each.key
    color       = each.value
    description = "Priority level for issues and PRs"
  }

}

resource "github_issue_labels" "type_labels" {
  repository = "compliance-template"
  for_each = {
    "type:feature"     = "0000FF" # Blue
    "type:bug"         = "FF00FF" # Magenta
    "type:docs"        = "00FFFF" # Cyan
    "type:performance" = "800080" # Purple
    "type:security"    = "FF0000" # Red
  }
  label {
    name        = each.key
    color       = each.value
    description = "Type of work"
  }

}

# WAF-specific labels to aid in well-architected improvement tracking
resource "github_issue_labels" "waf_labels" {
  repository = "compliance-template"
  for_each = {
    "waf:security"      = "B60205" # Dark red
    "waf:governance"    = "1D76DB" # Blue
    "waf:productivity"  = "0E8A16" # Green
    "waf:collaboration" = "5319E7" # Purple
    "waf:architecture"  = "FEF2C0" # Beige
  }
  label {
    name        = each.key
    color       = each.value
    description = "Well-Architected Framework improvement area"
  }

}

# Migration-specific labels to track progress
resource "github_issue_labels" "migration_labels" {
  repository = "compliance-template"
  for_each = {
    "migration:planning"    = "C5DEF5" # Light blue
    "migration:in-progress" = "FEF2C0" # Beige
    "migration:completed"   = "0E8A16" # Green
    "migration:blocked"     = "B60205" # Dark red
  }
  label {
    name        = each.key
    color       = each.value
    description = "Migration status tracking"
  }

}

# GitHub Actions workflows to automate collaboration
# Addresses anti-pattern: Manual process overhead
resource "github_repository_file" "issue_automation_workflow" {
  repository          = "compliance-template"
  branch              = "main"
  file                = ".github/workflows/issue-automation.yml"
  content             = file(local.template_files.issue_automation)
  commit_message      = "Add issue automation workflow via Terraform"
  commit_author       = "GitHub WAF"
  commit_email        = "waf@example.com"
  overwrite_on_create = true
}

resource "github_repository_file" "stale_issues_workflow" {
  repository          = "compliance-template"
  branch              = "main"
  file                = ".github/workflows/stale-issues.yml"
  content             = file(local.template_files.stale_issues)
  commit_message      = "Add stale issues workflow via Terraform"
  commit_author       = "GitHub WAF"
  commit_email        = "waf@example.com"
  overwrite_on_create = true
}

# Cross-repository visibility workflow
# Addresses anti-pattern: Siloed information in monorepos
resource "github_repository_file" "cross_repo_visibility_workflow" {
  repository          = "compliance-template"
  branch              = "main"
  file                = ".github/workflows/cross-repo-visibility.yml"
  content             = file(local.template_files.cross_repo)
  commit_message      = "Add cross-repository visibility workflow via Terraform"
  commit_author       = "GitHub WAF"
  commit_email        = "waf@example.com"
  overwrite_on_create = true
}

# Team meeting template
# Addresses anti-pattern: Unstructured meetings and lost context
resource "github_repository_file" "team_meeting_template" {
  repository          = "compliance-template"
  branch              = "main"
  file                = ".github/MEETING_TEMPLATE.md"
  content             = file(local.template_files.team_meeting)
  commit_message      = "Add team meeting template via Terraform"
  commit_author       = "GitHub WAF"
  commit_email        = "waf@example.com"
  overwrite_on_create = true
}

# Release template for consistent release notes
# Addresses anti-pattern: Inconsistent release documentation
resource "github_repository_file" "release_template" {
  repository          = "compliance-template"
  branch              = "main"
  file                = ".github/RELEASE_TEMPLATE.md"
  content             = file(local.template_files.release_template)
  commit_message      = "Add release template via Terraform"
  commit_author       = "GitHub WAF"
  commit_email        = "waf@example.com"
  overwrite_on_create = true
}

# Integration between Actions and Projects for automation
# Addresses anti-pattern: Manual status updates and tracking
resource "github_repository_file" "project_automation_workflow" {
  repository          = "compliance-template"
  branch              = "main"
  file                = ".github/workflows/project-automation.yml"
  content             = file(local.template_files.project_automation)
  commit_message      = "Add project automation workflow via Terraform"
  commit_author       = "GitHub WAF"
  commit_email        = "waf@example.com"
  overwrite_on_create = true
}

# Repository settings for team collaboration
resource "github_repository_collaborator" "cross_functional_members" {
  for_each = {
    for index, collab in var.cross_functional_collaborators : "${collab.repo}-${collab.username}" => collab
  }

  repository = each.value.repo
  username   = each.value.username
  permission = each.value.permission

  depends_on = [module.default_repo_settings]
}
