variable "governance_repository_name" {
  description = "Name of the repository used for Copilot governance and usage reporting"
  type        = string
  default     = "copilot-governance"
}

variable "visibility" {
  description = "Visibility of the Copilot governance repository (private, internal, public)"
  type        = string
  default     = "internal"
  validation {
    condition     = contains(["private", "internal", "public"], var.visibility)
    error_message = "Valid values for visibility are 'private', 'internal', or 'public'."
  }
}

variable "copilot_usage_workflow_path" {
  description = "Absolute path to the Copilot usage reporting workflow template"
  type        = string
  validation {
    condition     = var.copilot_usage_workflow_path != ""
    error_message = "copilot_usage_workflow_path must be a non-empty path to the workflow template file."
  }
}

variable "commit_author" {
  description = "Author used for workflow file commits"
  type        = string
  default     = "GitHub WAF"
}

variable "commit_email" {
  description = "Email used for workflow file commits"
  type        = string
  default     = "waf@example.com"
}

variable "copilot_labels" {
  description = "Map of label name to hex color code for Copilot governance labels"
  type        = map(string)
  default = {
    "copilot:adoption"   = "0E8A16"
    "copilot:governance" = "1D76DB"
    "copilot:cost"       = "FEF2C0"
    "copilot:security"   = "B60205"
  }
}

variable "copilot_team_id" {
  description = "GitHub team ID to assign admin access to the Copilot governance repository. Leave empty to skip team assignment."
  type        = string
  default     = ""
}
