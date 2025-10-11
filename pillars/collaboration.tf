# GitHub Well-Architected Framework - Collaboration Pillar

locals {
  repository_name = "compliance-template"

  template_files = {
    issue_forms = {
      bug_report = {
        repository_path = ".github/ISSUE_TEMPLATE/bug_report.yml"
        source_path     = abspath("${path.module}/../templates/issue_forms/bug_report.yml")
      }
      feature_request = {
        repository_path = ".github/ISSUE_TEMPLATE/feature_request.yml"
        source_path     = abspath("${path.module}/../templates/issue_forms/feature_request.yml")
      }
      monorepo_change = {
        repository_path = ".github/ISSUE_TEMPLATE/monorepo_change.yml"
        source_path     = abspath("${path.module}/../templates/issue_forms/monorepo_change.yml")
      }
      config = {
        repository_path = ".github/ISSUE_TEMPLATE/config.yml"
        source_path     = abspath("${path.module}/../templates/issue_forms/config.yml")
      }
    }
    documentation = {
      pr_template = {
        repository_path = ".github/PULL_REQUEST_TEMPLATE.md"
        source_path     = abspath("${path.module}/../templates/pull_request_template.md")
      }
      meeting_template = {
        repository_path = ".github/MEETING_TEMPLATE.md"
        source_path     = abspath("${path.module}/../templates/meeting_template.md")
      }
      release_template = {
        repository_path = ".github/RELEASE_TEMPLATE.md"
        source_path     = abspath("${path.module}/../templates/release_template.md")
      }
      discussion_categories = {
        repository_path = ".github/discussion-categories.yml"
        source_path     = abspath("${path.module}/../templates/discussion_categories.yml")
      }
    }
  }

  workflow_files = {
    issue_automation = {
      filename = "issue-automation.yml"
      source   = abspath("${path.module}/../templates/workflows/issue_automation.yml")
    }
    project_automation = {
      filename = "project-automation.yml"
      source   = abspath("${path.module}/../templates/workflows/project_automation.yml")
    }
    stale_issues = {
      filename = "stale-issues.yml"
      source   = abspath("${path.module}/../templates/workflows/stale_issues.yml")
    }
    cross_repo_visibility = {
      filename = "cross-repo-visibility.yml"
      source   = abspath("${path.module}/../templates/workflows/cross_repo_visibility.yml")
    }
  }
}

# Standardize collaboration templates using reusable module
module "collaboration_templates" {
  source     = "../modules/repository_templates"
  repository = local.repository_name
  files      = merge(local.template_files.issue_forms, local.template_files.documentation)
}

# Cross-repository labels for consistent tagging
# Addresses anti-pattern: Inconsistent labeling across repositories
module "priority_labels" {
  source     = "../modules/labels"
  repository = local.repository_name
  labels = {
    "priority:critical" = "FF0000"
    "priority:high"     = "FFA500"
    "priority:medium"   = "FFFF00"
    "priority:low"      = "00FF00"
  }
}

module "type_labels" {
  source     = "../modules/labels"
  repository = local.repository_name
  labels = {
    "type:feature"     = "0000FF"
    "type:bug"         = "FF00FF"
    "type:docs"        = "00FFFF"
    "type:performance" = "800080"
    "type:security"    = "FF0000"
  }
}

# WAF-specific labels to aid in well-architected improvement tracking
module "waf_labels" {
  source     = "../modules/labels"
  repository = local.repository_name
  labels = {
    "waf:security"      = "B60205"
    "waf:governance"    = "1D76DB"
    "waf:productivity"  = "0E8A16"
    "waf:collaboration" = "5319E7"
    "waf:architecture"  = "FEF2C0"
  }
}

# Migration-specific labels to track progress
module "migration_labels" {
  source     = "../modules/labels"
  repository = local.repository_name
  labels = {
    "migration:planning"    = "C5DEF5"
    "migration:in-progress" = "FEF2C0"
    "migration:completed"   = "0E8A16"
    "migration:blocked"     = "B60205"
  }
}

# GitHub Actions workflows to automate collaboration
module "collaboration_workflows" {
  for_each                = local.workflow_files
  source                  = "../modules/action"
  repository              = local.repository_name
  workflow_file           = each.value.filename
  workflow_file_path      = each.value.source
  workflow_commit_message = "Manage collaboration workflows via Terraform"
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
