variable "default_repo_config" {
  description = "Default configuration for repositories in the organization"
  type = object({
    has_wiki               = optional(bool, false)
    vulnerability_alerts   = optional(bool, true)
    has_projects           = optional(bool, true)
    delete_branch_on_merge = optional(bool, true)
    has_issues             = optional(bool, true)
    is_template            = optional(bool, false)
    archived               = optional(bool, false)
    topics                 = optional(list(string), [])
  })
  default = {
    has_wiki               = false
    vulnerability_alerts   = true
    has_projects           = true
    delete_branch_on_merge = true
    has_issues             = true
  }
}

variable "billing_email" {
  description = "Email address for billing notifications"
  type        = string
  default     = ""

}

variable "repositories" {
  description = "List of repositories to manage with their specific configurations"
  type = list(object({
    name                   = string
    description            = optional(string, "")
    homepage_url           = optional(string, "")
    visibility             = optional(string, "private")
    has_wiki               = optional(bool)
    vulnerability_alerts   = optional(bool)
    has_projects           = optional(bool)
    delete_branch_on_merge = optional(bool)
    has_issues             = optional(bool)
    is_template            = optional(bool)
    archived               = optional(bool)
    topics                 = optional(list(string))
    template = optional(object({
      owner                = string
      repository           = string
      include_all_branches = optional(bool, false)
    }))
    advanced_security               = optional(bool, false)
    secret_scanning                 = optional(bool, false)
    secret_scanning_push_protection = optional(bool, false)
  }))

}

variable "enforce_admins" {
  description = "Enforce repository rules on administrators"
  type        = bool
  default     = true
}

variable "organization_name" {
  description = "Name of the organization"
  type        = string
}

variable "teams" {
  description = "List of teams to manage with their specific configurations"
  type = list(object({
    name        = string
    description = optional(string, "")
    privacy     = optional(string, "closed")
    members     = optional(list(string), [])
    repositories = optional(list(object({
      name       = string
      permission = string
    })), [])
  }))

}
