variable "github_token" {
  type        = string
  description = "GitHub personal access token or GitHub Actions token"
  sensitive   = true
}

variable "github_organization" {
  type        = string
  description = "GitHub organization name"
  default     = ""
}

variable "github_username" {
  type        = string
  description = "GitHub username"
  default     = ""
}

variable "repository_visibility" {
  type        = string
  description = "Visibility of the repository (public or private)"
  default     = "private"
}

variable "billing_email" {
  type        = string
  description = "Billing email for the organization"
  default     = ""

}
