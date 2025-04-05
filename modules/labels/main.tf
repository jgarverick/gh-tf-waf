resource "github_issue_label" "labels" {
  for_each   = var.labels
  repository = var.repository
  name       = each.key
  color      = each.value
}
