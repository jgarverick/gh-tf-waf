variable "name" {
  type        = string
  description = "The name of the enterprise"
}

variable "description" {
  type        = string
  description = "A description of the enterprise"
  default     = ""
}

variable "administrators" {
  type        = list(string)
  description = "List of GitHub usernames who are administrators of the enterprise"
  default     = []
}

variable "github_token" {
  type        = string
  description = "GitHub personal access token with admin:enterprise scope"
  sensitive   = true
}

variable "billing_email" {
  type        = string
  description = "The email address to use for billing"
}

variable "location" {
  type        = string
  description = "The location of the enterprise"
  default     = "US"
}
variable "admin_logins" {
  description = "List of admin logins for the GitHub enterprise organization"
  type        = list(string)
}

variable "enterprise_id" {
  description = "The ID of the GitHub enterprise organization"
  type        = string
}
