output "secret_names" {
  description = "The name of the secret"
  value       = length(github_actions_environment_secret.secrets) > 0 ? github_actions_environment_secret.secrets : null
}

output "workflow_file" {
  description = "The name of the GitHub Actions workflow file added to the repository"
  value       = github_repository_file.workflow.file
}

output "workflow_branch" {
  description = "The branch to which the workflow file was committed"
  value       = github_repository_file.workflow.branch
}

output "secrets" {
  description = "A map of secrets added to the repository"
  value = {
    for key, secret in github_actions_environment_secret.secrets : key => {
      environment = secret.environment
      secret_name = secret.secret_name
    }
  }
}
