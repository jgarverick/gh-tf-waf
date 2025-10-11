locals {
  files = {
    for key, file in var.files : key => {
      repository_path = file.repository_path
      source_path     = file.source_path
      template_vars   = coalesce(file.template_vars, {})
      commit_message  = coalesce(file.commit_message, var.commit_message)
      commit_author   = coalesce(file.commit_author, var.commit_author)
      commit_email    = coalesce(file.commit_email, var.commit_email)
    }
  }
}

resource "github_repository_file" "managed_files" {
  for_each = local.files

  repository          = var.repository
  branch              = var.branch
  file                = each.value.repository_path
  content             = length(keys(each.value.template_vars)) > 0 ? templatefile(each.value.source_path, each.value.template_vars) : file(each.value.source_path)
  commit_message      = each.value.commit_message
  commit_author       = each.value.commit_author
  commit_email        = each.value.commit_email
  overwrite_on_create = true
}
