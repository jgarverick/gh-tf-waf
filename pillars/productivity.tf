# GitHub Well-Architected Framework - Productivity Pillar

locals {
  default_statuses = ["Backlog", "In Progress", "Blocked", "Ready for Review", "Done"]

  productivity_projects = [
    {
      name        = "Productivity Operations"
      description = "Standardized project board capturing automation throughput and operational readiness."
      readme      = <<-EOT
        # Productivity Operations

        This board tracks automation debt, GitHub Actions hygiene, and reporting required by the Productivity pillar of the GitHub Well-Architected Framework.

        ## Cadence
        - Prioritize automation debt weekly
        - Review blocked items during the platform sync
        - Ensure SLAs for stale workflow runs are met
      EOT
    }
  ]

  productivity_views = [
    {
      name       = "Throughput Overview"
      layout     = "board"
      fields     = ["Title", "Assignees", "Status", "Iteration", "Priority"]
      filter_by  = "Status"
      group_by   = "Iteration"
      sort_by    = "PRIORITY"
      sort_order = "ASC"
    },
    {
      name      = "Blocked Items"
      layout    = "table"
      fields    = ["Title", "Status", "Labels", "Updated At"]
      filter_by = "Labels"
      sort_by   = "UPDATED_AT"
    }
  ]

  productivity_workflows = {
    project_view = {
      repository = "productivity-repo"
      filename   = "project-view-automation.yml"
      source     = abspath("${path.module}/../templates/workflows/project_view_automation.yml")
    }
    stale_issues = {
      repository = "productivity-repo"
      filename   = "stale-issues.yml"
      source     = abspath("${path.module}/../templates/workflows/stale_issues.yml")
    }
  }
}

module "productivity_boards" {
  source            = "../modules/project_boards"
  organization_name = var.organization_name
  projects          = local.productivity_projects
  default_statuses  = local.default_statuses
  waf_custom_fields = true
}

module "productivity_views" {
  source            = "../modules/project_view"
  organization_name = var.organization_name
  project_number    = var.productivity_project_number
  views             = local.productivity_views
  enable_automation = true
  default_view_name = "Productivity Overview"
}

module "productivity_workflows" {
  for_each                = local.productivity_workflows
  source                  = "../modules/action"
  repository              = each.value.repository
  workflow_file           = each.value.filename
  workflow_file_path      = each.value.source
  workflow_commit_message = "Manage productivity workflows via Terraform"
}
