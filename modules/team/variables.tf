variable "name" {
  description = "Name of the team"
  type        = string
}

variable "description" {
  description = "Description of team purpose"
  type        = string
  default     = ""
}

variable "privacy" {
  description = "Level of privacy for the team (secret or closed)"
  type        = string
  default     = "closed"
  validation {
    condition     = contains(["secret", "closed"], var.privacy)
    error_message = "Valid values for privacy are 'secret' or 'closed'."
  }
}

variable "parent_team_id" {
  description = "ID of the parent team, if this is a nested team"
  type        = string
  default     = null
}

variable "members" {
  description = "GitHub usernames of team members"
  type        = list(string)
  default     = []
}

variable "maintainers" {
  description = "GitHub usernames of team maintainers"
  type        = list(string)
  default     = []
}

variable "repository_permissions" {
  description = "Map of repository names to permission levels"
  type        = map(string)
  default     = {}
  validation {
    condition = alltrue([
      for permission in values(var.repository_permissions) :
      contains(["pull", "triage", "push", "maintain", "admin"], permission)
    ])
    error_message = "Valid permission values: 'pull', 'triage', 'push', 'maintain', 'admin'"
  }
}

variable "create_default_maintainer" {
  description = "Whether to create a default maintainer for the team"
  type        = bool
  default     = false
}
