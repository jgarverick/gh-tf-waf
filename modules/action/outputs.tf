output "secret_name" {
  description = "The name of the secret"
  value       = github_actions_environment_secret.this.secret_name
}
