# Outputs file for the labels module

output "label_names" {
  description = "The names of the labels created"
  value       = [for label in github_issue_label.labels : label.name]
}

output "label_colors" {
  description = "The colors of the labels created"
  value       = [for label in github_issue_label.labels : label.color]
}
