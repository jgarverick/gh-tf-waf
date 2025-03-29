resource "github_organization_settings" "waf-appsec" {
  billing_email                            = var.billing_email
  default_repository_permission            = "read"
  members_can_create_repositories          = false
  members_can_create_public_repositories   = false
  members_can_create_private_repositories  = false
  members_can_create_internal_repositories = false
  members_can_create_pages                 = false

}
