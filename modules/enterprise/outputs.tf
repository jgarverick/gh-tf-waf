output "enterprise_id" {
  description = "The ID of the enterprise"
  value       = github_enterprise_organization.this.id
}

output "enterprise_name" {
  description = "The name of the enterprise"
  value       = github_enterprise_organization.this.name
}
