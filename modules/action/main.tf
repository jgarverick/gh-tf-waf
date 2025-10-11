locals {
  workflow_enabled = var.workflow_file != null && var.workflow_file_path != null && var.workflow_file != ""
}

resource "github_repository_file" "workflow" {
  count               = local.workflow_enabled ? 1 : 0
  repository          = var.repository
  branch              = var.branch
  file                = "${var.workflow_path}/${var.workflow_file}"
  content             = file(var.workflow_file_path)
  commit_message      = var.workflow_commit_message
  commit_author       = var.commit_author
  commit_email        = var.commit_email
  overwrite_on_create = true
}

resource "github_actions_environment_secret" "secrets" {
  for_each        = var.secrets != null ? var.secrets : {}
  repository      = var.repository
  environment     = each.value.environment
  secret_name     = each.key
  encrypted_value = each.value.encrypted_value
}
