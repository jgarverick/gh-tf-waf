# Project View Module for GitHub Well-Architected Framework
# Helps teams visualize work and optimize collaboration

locals {
  # GraphQL needs double quotes for string values, handle field formatting
  formatted_fields = {
    for idx, view in var.views : idx => [
      for field in coalesce(view.fields, ["Title", "Assignees", "Status"]) :
      "\"${field}\""
    ]
  }

  # Create view names with defaults for unnamed views
  view_names = {
    for idx, view in var.views : idx => coalesce(
      view.name,
      view.filter_by != null ? "${view.filter_by} View" :
      view.group_by != null ? "${view.group_by} Groups" :
      "${var.default_view_name} ${idx + 1}"
    )
  }

  # Build filter queries based on filter_by attribute
  filter_queries = {
    "Status"     = "status:\"In Progress\",\"To Do\",\"Done\""
    "Assignee"   = "assignee:@me"
    "Labels"     = "label:\"waf:security\",\"waf:governance\""
    "Repository" = "repo:\"${var.organization_name}/compliance-template\""
  }
}

# Create project views using GraphQL API (not available in standard Terraform provider)
resource "null_resource" "project_view" {
  for_each = { for idx, view in var.views : idx => view }

  # Changes to these values will trigger recreation
  triggers = {
    organization   = var.organization_name
    project_number = var.project_number
    view_name      = local.view_names[each.key]
    layout         = coalesce(each.value.layout, "board")
    fields         = join(",", local.formatted_fields[each.key])
    filter_by      = each.value.filter_by
    group_by       = each.value.group_by
    sort_by        = each.value.sort_by
    sort_order     = coalesce(each.value.sort_order, "DESC")
  }

  # Create the view using GitHub CLI
  provisioner "local-exec" {
    command = <<-EOT
      # Create project view with specific layout
      gh api graphql -f query='
        mutation {
          createProjectV2View(input: {
            projectId: "${var.organization_name}/projects/${var.project_number}"
            name: "${local.view_names[each.key]}"
            layout: ${upper(coalesce(each.value.layout, "board"))}
          }) {
            view {
              id
              name
            }
          }
        }
      ' --jq '.data.createProjectV2View.view.id' > /tmp/view_id_${each.key}

      # Add filters if specified
      VIEW_ID=$(cat /tmp/view_id_${each.key})
      ${each.value.filter_by != null ? "gh api graphql -f query='mutation { updateProjectV2View(input: { projectId: \"${var.organization_name}/projects/${var.project_number}\" viewId: \"'$VIEW_ID'\" filteredBy: { ${local.filter_queries[each.value.filter_by]} } }) { view { id } } }'" : "echo 'No filter specified'"}

      # Add grouping if specified
      ${each.value.group_by != null ? "gh api graphql -f query='mutation { updateProjectV2View(input: { projectId: \"${var.organization_name}/projects/${var.project_number}\" viewId: \"'$VIEW_ID'\" groupBy: \"${each.value.group_by}\" }) { view { id } } }'" : "echo 'No grouping specified'"}

      # Add sorting if specified
      ${each.value.sort_by != null ? "gh api graphql -f query='mutation { updateProjectV2View(input: { projectId: \"${var.organization_name}/projects/${var.project_number}\" viewId: \"'$VIEW_ID'\" sortBy: { field: \"${each.value.sort_by}\", direction: ${coalesce(each.value.sort_order, "DESC")} } }) { view { id } } }'" : "echo 'No sorting specified'"}

      # Configure visible fields
      gh api graphql -f query='
        mutation {
          updateProjectV2View(input: {
            projectId: "${var.organization_name}/projects/${var.project_number}"
            viewId: "'$VIEW_ID'"
            visibleFields: [${join(",", local.formatted_fields[each.key])}]
          }) {
            view { id }
          }
        }
      '
    EOT
  }

  # Cleanup temporary files
  provisioner "local-exec" {
    when    = destroy
    command = "rm -f /tmp/view_id_${each.key}"
  }
}

# Create automation for project views if enabled
# Addresses anti-pattern: Manual updates of project boards
resource "null_resource" "project_automation" {
  count = var.enable_automation ? 1 : 0

  depends_on = [null_resource.project_view]

  triggers = {
    organization   = var.organization_name
    project_number = var.project_number
  }

  # Create standard automation rules
  provisioner "local-exec" {
    command = <<-EOT
      # Auto-set new issues to "To Do" status
      gh api graphql -f query='
        mutation {
          createProjectV2Automation(input: {
            projectId: "${var.organization_name}/projects/${var.project_number}"
            name: "Auto-triage new issues"
            triggerNode: {trigger: ADDED_TO_PROJECT, type: ISSUE}
            actionNode: {action: SET_FIELD_VALUE, fieldId: "Status", value: "To Do"}
          }) {
            projectV2Automation { id }
          }
        }
      '

      # Auto-set PRs to "In Progress" status
      gh api graphql -f query='
        mutation {
          createProjectV2Automation(input: {
            projectId: "${var.organization_name}/projects/${var.project_number}"
            name: "Auto-track PR progress"
            triggerNode: {trigger: ADDED_TO_PROJECT, type: PULL_REQUEST}
            actionNode: {action: SET_FIELD_VALUE, fieldId: "Status", value: "In Progress"}
          }) {
            projectV2Automation { id }
          }
        }
      '

      # Auto-close items when linked PRs are merged
      gh api graphql -f query='
        mutation {
          createProjectV2Automation(input: {
            projectId: "${var.organization_name}/projects/${var.project_number}"
            name: "Auto-close completed items"
            triggerNode: {trigger: PR_MERGED, type: PULL_REQUEST}
            actionNode: {action: SET_FIELD_VALUE, fieldId: "Status", value: "Done"}
          }) {
            projectV2Automation { id }
          }
        }
      '
    EOT
  }
}
