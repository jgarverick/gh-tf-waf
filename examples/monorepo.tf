# Example: Monorepo configuration

# Create a monorepo repository
resource "github_repository" "monorepo" {
  name         = "monorepo"
  description  = "Monorepo managed by Terraform"
  visibility   = "private"
  has_issues   = true
  has_projects = true
  has_wiki     = true
}

# Branch protection rule for the monorepo
resource "github_branch_protection" "monorepo_branch_protection" {
  repository_id = github_repository.monorepo.node_id

  pattern = "main" # Specify the branch pattern for the monorepo

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
    required_approving_review_count = 2 # Increased review count for monorepo
  }

  required_status_checks {
    strict   = true
    contexts = ["ci/lint", "ci/test"] # More comprehensive checks
  }
  force_push_bypassers = []


}
