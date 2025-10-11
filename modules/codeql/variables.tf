variable "repositories" {
  description = "Map of repositories that require CodeQL workflows"
  type = map(object({
    languages     = optional(list(string))
    branch        = optional(string)
    workflow_file = optional(string)
  }))
}

variable "default_languages" {
  description = "Languages to scan when repository does not override"
  type        = list(string)
  default     = ["javascript"]
}

variable "default_branch" {
  description = "Default branch to which the workflow is committed"
  type        = string
  default     = "main"
}

variable "workflow_filename" {
  description = "Default filename for the CodeQL workflow"
  type        = string
  default     = "codeql.yml"
}

variable "workflow_template_path" {
  description = "Absolute path to the CodeQL workflow template"
  type        = string
}

variable "commit_message" {
  description = "Commit message used when adding the workflow"
  type        = string
  default     = "Add CodeQL workflow via Terraform"
}

variable "commit_author" {
  description = "Author used for the CodeQL workflow commit"
  type        = string
  default     = "GitHub WAF"
}

variable "commit_email" {
  description = "Email used for the CodeQL workflow commit"
  type        = string
  default     = "waf@example.com"
}
