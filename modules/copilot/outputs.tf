output "governance_repository_name" {
  description = "Name of the Copilot governance repository"
  value       = github_repository.copilot_governance.name
}

output "governance_repository_url" {
  description = "HTML URL of the Copilot governance repository"
  value       = github_repository.copilot_governance.html_url
}
