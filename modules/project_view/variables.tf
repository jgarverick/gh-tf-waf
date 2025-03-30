variable "organization_name" {
  description = "The GitHub organization name"
  type        = string
}

variable "project_number" {
  description = "The number of the GitHub project"
  type        = number
}

variable "views" {
  description = "List of project view configurations"
  type = list(object({
    name       = optional(string)
    layout     = optional(string, "board") # Default to board layout
    fields     = optional(list(string), ["Title", "Assignees", "Status"])
    filter_by  = optional(string, "Status") # Default filter
    group_by   = optional(string)
    sort_by    = optional(string)
    sort_order = optional(string, "DESC") # Default sort order
  }))
  default = []

  validation {
    condition = alltrue([
      for view in var.views : contains(["board", "table", "roadmap"], coalesce(view.layout, "board"))
    ])
    error_message = "Layout must be one of: board, table, roadmap"
  }

  validation {
    condition = alltrue([
      for view in var.views : contains(["ASC", "DESC"], coalesce(view.sort_order, "DESC"))
    ])
    error_message = "Sort order must be either ASC or DESC"
  }
}

variable "default_view_name" {
  description = "Name for the default project view if creating a new one"
  type        = string
  default     = "Default View"
}

variable "enable_automation" {
  description = "Whether to enable automation for this project view"
  type        = bool
  default     = true
}
