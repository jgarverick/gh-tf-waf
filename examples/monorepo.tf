# Example: Monorepo configuration

# Create a monorepo repository using the repo module
module "monorepo" {
  source            = "../modules/repo"
  organization_name = var.github_organization
  repositories      = []
  teams             = []

}

# Branch protection rule for the monorepo using the branch_protection module
module "monorepo_branch_protection" {
  source = "../modules/ruleset"
  rules = {
    required_reviewers    = 2
    dismiss_stale_reviews = true
  }
  target_repositories = [module.monorepo.repositories[0].name]

}
