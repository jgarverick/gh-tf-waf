resource "github_actions_environment_secret" "this" {
  repository      = var.repository
  environment     = var.environment
  secret_name     = var.secret_name
  encrypted_value = var.encrypted_value
}
