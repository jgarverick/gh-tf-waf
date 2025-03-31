# Example: Single repository configuration

# Create a repository
resource "github_repository" "example_repo" {
  name         = "example-repository"
  description  = "Example repository managed by Terraform"
  visibility   = "private"
  has_issues   = true
  has_projects = true
  has_wiki     = false
}

# Branch protection rule (example)
resource "github_branch_protection" "branch_protection" {
  repository_id = github_repository.example_repo.node_id
  pattern       = "main"

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
    required_approving_review_count = 1
  }

  required_status_checks {
    strict   = true
    contexts = ["ci/test"] # Replace with your CI context
  }


  force_push_bypassers = []
}
