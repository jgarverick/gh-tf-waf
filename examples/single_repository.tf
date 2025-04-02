# Example: Single repository configuration

# Create a repository using the repo module
module "example_repo" {
  source            = "../modules/repo"
  organization_name = var.github_organization
  repositories      = []
  teams             = []
}

# Branch protection rule using the branch_protection module
module "branch_protection" {
  source             = "../modules/ruleset"
  name               = "example-repo-branch-protection"
  protected_branches = ["default"]
  rules = {
    required_reviewers    = 2
    dismiss_stale_reviews = true
  }
  target_repositories = []
}
