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
  token = env("GITHUB_TOKEN")
  owner = env("GITHUB_OWNER")
}
