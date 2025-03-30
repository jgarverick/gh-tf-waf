output "project_ids" {
  description = "Map of project names to their IDs"
  value       = { for name, project in github_organization_project.projects : name => project.id }
}

output "project_numbers" {
  description = "Map of project names to their numbers (used in URLs)"
  value       = { for name, project in github_organization_project.projects : name => project.number }
}

output "project_urls" {
  description = "Map of project names to their URLs"
  value       = { for name, project in github_organization_project.projects : name => project.url }
}
