variable "repository" {
  description = "GitHub repository to manage"
  type        = string
}

variable "branch" {
  description = "Branch to commit files into"
  type        = string
  default     = "main"
}

variable "files" {
  description = "Map of template files to manage"
  type = map(object({
    repository_path = string
    source_path     = string
    template_vars   = optional(map(string))
    commit_message  = optional(string)
    commit_author   = optional(string)
    commit_email    = optional(string)
  }))
}

variable "commit_message" {
  description = "Default commit message"
  type        = string
  default     = "Manage repository templates via Terraform"
}

variable "commit_author" {
  description = "Default commit author"
  type        = string
  default     = "GitHub WAF"
}

variable "commit_email" {
  description = "Default commit email"
  type        = string
  default     = "waf@example.com"
}
