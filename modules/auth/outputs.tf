# Example: Output the SAML SSO URL
output "saml_sso_url" {
  description = "The SAML SSO URL"
  value       = var.saml_sso_url
}

# Example: Output the OIDC issuer URI
output "oidc_issuer_uri" {
  description = "The OIDC issuer URI"
  value       = var.oidc_issuer_uri
}
