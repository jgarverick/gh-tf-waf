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
      # Create status field with predefined options
      gh api graphql -f query='
        mutation {
          createProjectV2Field(input: {
            projectId: "${each.value.id}"
            dataType: SINGLE_SELECT
            name: "Status"
            singleSelectOptions: [
              ${join(",", [for status in var.default_statuses : "{name: \"${status}\"}"])}
            ]
          }) {
            projectV2Field {
              id
            }
          }
        }
      '
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
      # Add WAF layer field
      gh api graphql -f query='
        mutation {
          createProjectV2Field(input: {
            projectId: "${each.value.id}"
            dataType: SINGLE_SELECT
            name: "WAF Layer"
            singleSelectOptions: [
              {name: "Security"},
              {name: "Governance"},
              {name: "Productivity"},
              {name: "Collaboration"},
              {name: "Architecture"}
            ]
          }) {
            projectV2Field {
              id
            }
          }
        }
      '

      # Add impact level field
      gh api graphql -f query='
        mutation {
          createProjectV2Field(input: {
            projectId: "${each.value.id}"
            dataType: SINGLE_SELECT
            name: "Impact"
            singleSelectOptions: [
              {name: "High"},
              {name: "Medium"},
              {name: "Low"}
            ]
          }) {
            projectV2Field {
              id
            }
          }
        }
      '

      # Add migration readiness field for migration tracking
      gh api graphql -f query='
        mutation {
          createProjectV2Field(input: {
            projectId: "${each.value.id}"
            dataType: SINGLE_SELECT
            name: "Migration Readiness"
            singleSelectOptions: [
              {name: "Not Started"},
              {name: "Planning"},
              {name: "In Progress"},
              {name: "Ready"},
              {name: "Completed"},
              {name: "N/A"}
            ]
          }) {
            projectV2Field {
              id
            }
          }
        }
      '

      # Add monorepo component tracking field
      gh api graphql -f query='
        mutation {
          createProjectV2Field(input: {
            projectId: "${each.value.id}"
            dataType: TEXT
            name: "Affected Components"
          }) {
            projectV2Field {
              id
            }
          }
        }
      '
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
      # Add README content
      gh api graphql -f query='
        mutation {
          updateProjectV2(input: {
            projectId: "${each.value.id}"
            readme: """${lookup(
    { for project in var.projects : project.name => project },
    each.value.name,
    { readme = "" }
).readme}"""
          }) {
            projectV2 {
              id
            }
          }
        }
      '
    EOT
}
}
