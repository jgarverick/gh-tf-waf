output "workflow_files" {
  description = "Map of repositories to the workflow file paths provisioned"
  value = {
    for name, file in github_repository_file.codeql_workflow : name => file.file
  }
}
