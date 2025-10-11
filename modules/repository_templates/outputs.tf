output "managed_paths" {
  description = "List of files managed in the repository"
  value       = [for file in github_repository_file.managed_files : file.file]
}
