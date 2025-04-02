# Combined configuration for all pillars
organization_name = "example-org"
billing_email     = "billing@example.com"

teams = [
  {
    name        = "appsec-team"
    description = "Team responsible for application security."
    privacy     = "closed"
    members     = ["security-lead", "security-engineer"]
    repositories = [
      {
        name       = "appsec-repo"
        permission = "admin"
      }
    ]
  },
  {
    name        = "architecture-team"
    description = "Team responsible for system architecture."
    privacy     = "closed"
    members     = ["architect-lead", "architect-engineer"]
    repositories = [
      {
        name       = "architecture-repo"
        permission = "admin"
      }
    ]
  },
  {
    name        = "collaboration-team"
    description = "Team responsible for collaboration tools and processes."
    privacy     = "closed"
    members     = ["collab-lead", "collab-engineer"]
    repositories = [
      {
        name       = "collaboration-repo"
        permission = "admin"
      }
    ]
  },
  {
    name        = "governance-team"
    description = "Team responsible for governance policies."
    privacy     = "closed"
    members     = ["governance-lead", "governance-engineer"]
    repositories = [
      {
        name       = "governance-repo"
        permission = "admin"
      }
    ]
  },
  {
    name        = "productivity-team"
    description = "Team responsible for productivity tools and processes."
    privacy     = "closed"
    members     = ["productivity-lead", "productivity-engineer"]
    repositories = [
      {
        name       = "productivity-repo"
        permission = "admin"
      }
    ]
  }
]

repositories = [
  {
    name        = "appsec-repo"
    description = "Repository for application security configurations."
    visibility  = "private"
    auto_init   = true
  },
  {
    name        = "architecture-repo"
    description = "Repository for architecture diagrams and configurations."
    visibility  = "private"
    auto_init   = true
  },
  {
    name        = "collaboration-repo"
    description = "Repository for collaboration tools and configurations."
    visibility  = "private"
    auto_init   = true
  },
  {
    name        = "governance-repo"
    description = "Repository for governance policies and configurations."
    visibility  = "private"
    auto_init   = true
  },
  {
    name        = "productivity-repo"
    description = "Repository for productivity tools and configurations."
    visibility  = "private"
    auto_init   = true
  }
]
