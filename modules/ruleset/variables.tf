variable "name" {
  description = "Name of the ruleset"
  type        = string
  default     = "Default Ruleset"
}

variable "target_type" {
  description = "The type of target for the ruleset (branch or tag)"
  type        = string
  default     = "branch"
  validation {
    condition     = contains(["branch", "tag"], var.target_type)
    error_message = "Valid values for target_type are 'branch' or 'tag'"
  }
}

variable "enforcement" {
  description = "The enforcement level of the ruleset (active, evaluate, disabled)"
  type        = string
  default     = "active"
  validation {
    condition     = contains(["active", "evaluate", "disabled"], var.enforcement)
    error_message = "Valid values for enforcement are 'active', 'evaluate', or 'disabled'"
  }
}

variable "bypass_actors" {
  description = "List of actors that can bypass this ruleset"
  type = list(object({
    actor_id    = string
    actor_type  = string
    bypass_mode = string
  }))
  default = []
  validation {
    condition = alltrue([
      for actor in var.bypass_actors : contains(["OrganizationAdmin", "RepositoryAdmin", "Team"], actor.actor_type)
    ])
    error_message = "Valid values for actor_type are 'OrganizationAdmin', 'RepositoryAdmin', or 'Team'"
  }
}

variable "rules" {
  description = "Map of rules to enable in this ruleset"
  type = object({
    creation                  = optional(bool, false),
    update                    = optional(bool, false),
    deletion                  = optional(bool, false),
    required_signatures       = optional(bool, false),
    required_linear_history   = optional(bool, false),
    required_deployments      = optional(bool, false),
    required_reviewers        = optional(number, 0),
    dismiss_stale_reviews     = optional(bool, false),
    require_code_owner_review = optional(bool, false),
    allow_force_pushes        = optional(bool, false),
    allow_deletions           = optional(bool, false)
  })
  default = {}
}

variable "target_repositories" {
  description = "List of repository IDs to apply this ruleset to (only used when target_type is 'repository')"
  type        = list(string)
  default     = []
}

variable "protected_branches" {
  description = "List of branch patterns to protect"
  type        = list(string)
  default     = ["main", "master", "production", "release/*"]
}
