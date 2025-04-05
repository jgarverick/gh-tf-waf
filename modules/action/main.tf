resource "github_repository_file" "workflow" {
  repository     = var.repository
  file           = var.workflow_file != null ? "${var.workflow_path}/${var.workflow_file}" : null
  content        = var.workflow_file_path != null ? filebase64(var.workflow_file_path) : null
  commit_message = "Add GitHub Actions workflow file"
  branch         = var.branch
  lifecycle {
    ignore_changes = [content] # Prevent unnecessary updates if content is null
  }
}

resource "github_actions_environment_secret" "secrets" {
  for_each        = var.secrets != null ? var.secrets : {}
  repository      = var.repository
  environment     = each.value.environment
  secret_name     = each.key
  encrypted_value = each.value.encrypted_value
}
