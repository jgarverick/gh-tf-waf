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

# Create multiple repositories using for_each
resource "github_repository" "multiple_repos" {
  for_each     = { for repo in local.repositories : repo.name => repo }
  name         = each.value.name
  description  = each.value.description
  visibility   = each.value.visibility
  has_issues   = true
  has_projects = true
  has_wiki     = false
}
