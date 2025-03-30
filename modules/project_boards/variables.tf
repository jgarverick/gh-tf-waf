variable "organization_name" {
  description = "The GitHub organization name"
  type        = string
}

variable "projects" {
  description = "List of project boards to create"
  type = list(object({
    name        = string
    description = optional(string, "")
    readme      = optional(string, "# Project Overview\nThis project board follows GitHub Well-Architected Framework best practices.")
    public      = optional(bool, false)
  }))
  default = []
}

variable "default_statuses" {
  description = "Default status options to create for each project"
  type        = list(string)
  default     = ["To Do", "In Progress", "In Review", "Done"]
}

variable "waf_custom_fields" {
  description = "Whether to add WAF-specific custom fields"
  type        = bool
  default     = true
}
