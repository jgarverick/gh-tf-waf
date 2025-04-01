# Project Boards Module for GitHub Well-Architected Framework
# Creates project boards with standardized fields and statuses
# Addresses anti-pattern: Inconsistent tracking across repositories

resource "github_organization_project" "projects" {
  for_each = { for idx, project in var.projects : project.name => project }

  name = each.value.name
  body = each.value.description

}

# Add default status field to each project
# Addresses anti-pattern: Inconsistent workflow tracking
resource "null_resource" "add_status_field" {
  for_each = github_organization_project.projects

  triggers = {
    project_id = each.value.id
    statuses   = join(",", var.default_statuses)
  }

  provisioner "local-exec" {
    command = <<-EOT
      gh api graphql -f query=@/workspaces/gh-tf-waf/templates/create_status_field.graphql
    EOT
  }
}

# Add WAF-specific custom fields if enabled
# Addresses anti-pattern: Missing structured information for WAF reviews
resource "null_resource" "add_waf_fields" {
  for_each = var.waf_custom_fields ? github_organization_project.projects : {}

  depends_on = [null_resource.add_status_field]

  triggers = {
    project_id = each.value.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      gh api graphql -f query=@/workspaces/gh-tf-waf/templates/create_waf_layer_field.graphql

      gh api graphql -f query=@/workspaces/gh-tf-waf/templates/create_impact_field.graphql

      gh api graphql -f query=@/workspaces/gh-tf-waf/templates/create_migration_readiness_field.graphql

      gh api graphql -f query=@/workspaces/gh-tf-waf/templates/create_affected_components_field.graphql
    EOT
  }
}

# Add README content to each project
resource "null_resource" "add_readme" {
  for_each = github_organization_project.projects

  depends_on = [
    null_resource.add_status_field,
    null_resource.add_waf_fields
  ]

  triggers = {
    project_id = each.value.id
    readme = lookup(
      { for project in var.projects : project.name => project },
      each.value.name,
      { readme = "" }
    ).readme
  }

  provisioner "local-exec" {
    command = <<-EOT
      gh api graphql -f query=@/workspaces/gh-tf-waf/templates/update_project_readme.graphql
    EOT
  }
}
