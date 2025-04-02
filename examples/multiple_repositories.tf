# Example: Multiple repositories configuration

# List of repositories to create
locals {
  repositories = [
    {
      name        = "repo-one"
      description = "First repository"
      visibility  = "private"
    },
    {
      name        = "repo-two"
      description = "Second repository"
      visibility  = "public"
    }
  ]
}

# Create multiple repositories using the repo module
module "multiple_repos" {
  source = "../modules/repo"

  organization_name = var.github_organization
  repositories      = local.repositories
  teams             = []
}
