locals {
  appsec_codeql_targets = {
    "compliance-template" = {
      languages     = ["javascript", "python"]
      workflow_file = "codeql-compliance.yml"
    }
    "security-policies" = {
      languages     = ["javascript"]
      workflow_file = "codeql-security.yml"
    }
  }
}

module "appsec_settings" {
  source                                                       = "../modules/org"
  billing_email                                                = var.billing_email
  organization_name                                            = var.organization_name
  default_repository_permission                                = "read"
  members_can_create_repositories                              = false
  members_can_create_public_repositories                       = false
  members_can_create_private_repositories                      = false
  members_can_create_internal_repositories                     = false
  members_can_create_pages                                     = false
  dependabot_alerts_enabled_for_new_repositories               = true
  dependency_graph_enabled_for_new_repositories                = true
  secret_scanning_push_protection_enabled_for_new_repositories = true
  secret_scanning_enabled_for_new_repositories                 = true
  dependabot_security_updates_enabled_for_new_repositories     = true
}

module "appsec_codeql" {
  source                 = "../modules/codeql"
  repositories           = local.appsec_codeql_targets
  workflow_template_path = abspath("${path.module}/../templates/workflows/codeql.yml")
  workflow_filename      = "codeql.yml"
  commit_message         = "Add CodeQL workflow via Terraform"
  commit_author          = "GitHub WAF"
  commit_email           = "waf@example.com"
}
