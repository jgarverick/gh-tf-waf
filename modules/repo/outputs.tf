output "repository_urls" {
  description = "Map of repository names to their URLs"
  value       = { for repo in github_repository.repositories : repo.name => repo.html_url }
}

output "repositories" {
  description = "Map of repository names to their full resource objects"
  value       = github_repository.repositories
}

output "default_configuration" {
  description = "The default repository configuration applied"
  value       = var.default_repo_config
}
