# Combined configuration for all pillars
organization_name = "obliteracy-waf"
billing_email     = "josh.garverick@gmail.com"
projects = [
  {
    name        = "appsec"
    description = "Application security project."
    readme      = "This is the README for the application security project."
  },
  {
    name        = "architecture"
    description = "Architecture project."
    readme      = "This is the README for the architecture project."
  },
  {
    name        = "collaboration"
    description = "Collaboration project."
    readme      = "This is the README for the collaboration project."
  },
  {
    name        = "governance"
    description = "Governance project."
    readme      = "This is the README for the governance project."
  },
  {
    name        = "productivity"
    description = "Productivity project."
    readme      = "This is the README for the productivity project."
  }
]
teams = [
  {
    name        = "appsec-team"
    description = "Team responsible for application security."
    privacy     = "closed"
    members     = ["jgarverick"]
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
    members     = ["jgarverick"]
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
    members     = ["jgarverick"]
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
    members     = ["jgarverick"]
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
    members     = ["jgarverick"]
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
