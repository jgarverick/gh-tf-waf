output "view_names" {
  description = "Map of view indexes to their names"
  value       = local.view_names
}

output "project_url" {
  description = "URL to the project board"
  value       = "https://github.com/orgs/${var.organization_name}/projects/${var.project_number}"
}

output "view_count" {
  description = "Number of views created"
  value       = length(var.views)
}
