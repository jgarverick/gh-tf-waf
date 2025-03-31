# SAML variables
variable "saml_sso_url" {
  type        = string
  description = "The SSO URL for SAML authentication"
  default     = ""
}

variable "saml_issuer_url" {
  type        = string
  description = "The issuer URL for SAML authentication"
  default     = ""
}

variable "saml_idp_certificate" {
  type        = string
  description = "The IdP certificate for SAML authentication"
  default     = ""
}

# OIDC variables
variable "oidc_issuer_uri" {
  type        = string
  description = "The issuer URI for OIDC authentication"
  default     = ""
}

variable "oidc_client_id" {
  type        = string
  description = "The client ID for OIDC authentication"
  default     = ""
}

variable "oidc_client_secret" {
  type        = string
  description = "The client secret for OIDC authentication"
  sensitive   = true
  default     = ""
}
