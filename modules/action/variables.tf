variable "repository" {
  type        = string
  description = "The GitHub repository name"
}

variable "environment" {
  type        = string
  default     = null
  description = "The GitHub environment name"
}

variable "secret_name" {
  type        = string
  default     = null
  description = "The name of the secret"
}

variable "encrypted_value" {
  type        = string
  default     = null
  description = "The encrypted value of the secret"
}

variable "workflow_file" {
  type        = string
  description = "The name of the GitHub Actions workflow file"
}

variable "workflow_file_path" {
  type        = string
  description = "The local path to the GitHub Actions workflow file"
}

variable "workflow_path" {
  type        = string
  default     = ".github/workflows"
  description = "The path in the repository where the workflow file will be stored"
}

variable "branch" {
  type        = string
  default     = "main"
  description = "The branch to which the workflow file will be committed"
}

variable "secrets" {
  type = map(object({
    environment     = string
    encrypted_value = string
  }))
  default     = null
  description = "A map of secrets to be added, where the key is the secret name and the value is an object containing the environment and encrypted value"
}
