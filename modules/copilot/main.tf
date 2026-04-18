# Copilot governance module implementing GitHub Well-Architected Framework best practices
# Addresses WAF guidance on managing GitHub Copilot at enterprise scale:
#   - Create a dedicated governance repository for Copilot policies
#   - Deploy standardized usage-reporting and seat-management workflows
#   - Apply consistent labels to track Copilot-related work items
#
# References:
#   - https://wellarchitected.github.com/library/productivity/checklist/
#   - https://wellarchitected.github.com/library/governance/checklist/

# Dedicated repository for tracking Copilot governance and usage
resource "github_repository" "copilot_governance" {
  name        = var.governance_repository_name
  description = "GitHub Copilot governance, usage reporting, and seat management"
  visibility  = var.visibility

  has_issues   = true
  has_projects = true
  has_wiki     = false

  # WAF: Keep branch history clean
  allow_merge_commit     = false
  allow_squash_merge     = true
  allow_rebase_merge     = true
  delete_branch_on_merge = true

  # WAF: Enable security features on governance repository
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

  auto_init = true
}

# Deploy Copilot usage-reporting workflow
resource "github_repository_file" "copilot_usage_workflow" {
  repository          = github_repository.copilot_governance.name
  branch              = "main"
  file                = ".github/workflows/copilot-usage-report.yml"
  content             = file(var.copilot_usage_workflow_path)
  commit_message      = "Add Copilot usage reporting workflow via Terraform"
  commit_author       = var.commit_author
  commit_email        = var.commit_email
  overwrite_on_create = true

  depends_on = [github_repository.copilot_governance]
}

# Labels to track Copilot-related work items across the governance repository
# WAF: Consistent labeling for cross-team visibility
resource "github_issue_label" "copilot_labels" {
  for_each = var.copilot_labels

  repository  = github_repository.copilot_governance.name
  name        = each.key
  color       = each.value
  description = "Copilot governance label: ${each.key}"

  depends_on = [github_repository.copilot_governance]
}

# Assign the Copilot governance team to the governance repository
resource "github_team_repository" "copilot_team_access" {
  count = var.copilot_team_id != "" ? 1 : 0

  team_id    = var.copilot_team_id
  repository = github_repository.copilot_governance.name
  permission = "admin"

  depends_on = [github_repository.copilot_governance]
}
