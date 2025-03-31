variable "repository" {
  type        = string
  description = "The GitHub repository name"
}

variable "environment" {
  type        = string
  description = "The GitHub environment name"
}

variable "secret_name" {
  type        = string
  description = "The name of the secret"
}

variable "encrypted_value" {
  type        = string
  description = "The encrypted value of the secret"
}
