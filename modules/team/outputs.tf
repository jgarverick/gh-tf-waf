output "team_id" {
  description = "ID of the created team"
  value       = github_team.team.id
}

output "team_name" {
  description = "Name of the created team"
  value       = github_team.team.name
}

output "team_slug" {
  description = "Slug of the created team, used for API operations"
  value       = github_team.team.slug
}

output "members" {
  description = "List of team members"
  value       = var.members
}

output "maintainers" {
  description = "List of team maintainers"
  value       = var.maintainers
}
