terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "github" {
  token = var.github_token
  owner = var.github_organization
}

variable "github_token" {
  type        = string
  description = "GitHub personal access token"
  sensitive   = true
}

variable "github_organization" {
  type        = string
  description = "GitHub organization name"
}
