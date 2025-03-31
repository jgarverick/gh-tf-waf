
resource "github_enterprise_organization" "this" {
  enterprise_id = var.enterprise_id
  admin_logins  = var.admin_logins
  billing_email = var.billing_email
  description   = var.description
  name          = var.name

}
