locals {
  repositories = {
    for name, config in var.repositories : name => {
      languages         = coalesce(config.languages, var.default_languages)
      branch            = coalesce(config.branch, var.default_branch)
      workflow_file     = coalesce(config.workflow_file, var.workflow_filename)
      languages_display = join(", ", coalesce(config.languages, var.default_languages))
      languages_json    = jsonencode(coalesce(config.languages, var.default_languages))
    }
  }
}

resource "github_repository_file" "codeql_workflow" {
  for_each = local.repositories

  repository = each.key
  branch     = each.value.branch
  file       = ".github/workflows/${each.value.workflow_file}"
  content = templatefile(var.workflow_template_path, {
    languages_display = each.value.languages_display
    languages_json    = each.value.languages_json
  })
  commit_message      = var.commit_message
  commit_author       = var.commit_author
  commit_email        = var.commit_email
  overwrite_on_create = true
}
