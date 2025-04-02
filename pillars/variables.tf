variable "billing_email" {
  description = "The email address for billing notifications."
  type        = string
}

variable "governance_team_members" {
  description = "List of users to be added to the governance team"
  type        = list(string)
  default     = []
}

variable "governance_team_maintainers" {
  description = "List of users to be maintainers of the governance team"
  type        = list(string)
  default     = []
}

variable "admin_team_id" {
  description = "ID of the administrators team that can bypass rules"
  type        = string
  default     = "admin"
}

variable "security_team_members" {
  description = "List of users to be added to the security team"
  type        = list(string)
  default     = []
}

variable "security_team_maintainers" {
  description = "List of users to be maintainers of the security team"
  type        = list(string)
  default     = []
}

variable "organization_name" {
  description = "GitHub organization name"
  type        = string
}
# Add your variable declarations here

variable "cross_functional_collaborators" {
  description = "List of cross-functional collaborators with repository, username, and permission details"
  type = list(object({
    repo       = string
    username   = string
    permission = string
  }))
  default = []
}
