output "ruleset_id" {
  description = "ID of the created ruleset"
  value       = github_repository_ruleset.default.id
}

output "ruleset_name" {
  description = "Name of the created ruleset"
  value       = github_repository_ruleset.default.name
}

output "enforcement_level" {
  description = "Current enforcement level of the ruleset"
  value       = github_repository_ruleset.default.enforcement
}

output "protected_branches" {
  description = "List of branch patterns protected by this ruleset"
  value       = var.protected_branches
}
