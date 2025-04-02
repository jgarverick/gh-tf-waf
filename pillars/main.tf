# This script will take the input from combined.tfvars and execute the pillar code in the `pillars` directory.


variable "teams" {
  type = list(object({
    name        = string
    description = string
    privacy     = string
    members     = list(string)
    repositories = list(object({
      name       = string
      permission = string
    }))
  }))
}

variable "repositories" {
  type = list(object({
    name        = string
    description = string
    visibility  = string
    auto_init   = bool
  }))
}

module "appsec" {
  source            = "../modules/repo"
  organization_name = var.organization_name
  billing_email     = var.billing_email
  teams             = var.teams
  repositories      = [for repo in var.repositories : repo if repo.name == "appsec-repo"]
}

module "architecture" {
  source            = "../modules/repo"
  organization_name = var.organization_name
  billing_email     = var.billing_email
  teams             = var.teams
  repositories      = [for repo in var.repositories : repo if repo.name == "architecture-repo"]
}

module "collaboration" {
  source            = "../modules/repo"
  organization_name = var.organization_name
  billing_email     = var.billing_email
  teams             = var.teams
  repositories      = [for repo in var.repositories : repo if repo.name == "collaboration-repo"]
}

module "governance" {
  source            = "../modules/repo"
  organization_name = var.organization_name
  billing_email     = var.billing_email
  teams             = var.teams
  repositories      = [for repo in var.repositories : repo if repo.name == "governance-repo"]
}

module "productivity" {
  source            = "../modules/repo"
  organization_name = var.organization_name
  teams             = var.teams
  billing_email     = var.billing_email
  repositories      = [for repo in var.repositories : repo if repo.name == "productivity-repo"]
}
