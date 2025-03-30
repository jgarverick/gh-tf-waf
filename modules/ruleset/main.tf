# This ruleset module implements GitHub's recommended practices for branch protection
# and repository governance, aligned with the Well-Architected Framework

resource "github_repository_ruleset" "default" {
  name        = var.name
  target      = var.target_type
  enforcement = var.enforcement

  # Define branch protection patterns
  conditions {
    ref_name {
      include = var.protected_branches
      exclude = []
    }
  }

  # Branch creation rules
  dynamic "rules" {
    for_each = var.rules.creation ? [1] : []
    content {
      creation = var.rules.creation
    }
  }

  # Branch update rules
  dynamic "rules" {
    for_each = var.rules.update ? [1] : []
    content {
      update = var.rules.update
    }
  }

  # Branch deletion rules
  dynamic "rules" {
    for_each = var.rules.deletion ? [1] : []
    content {
      deletion = var.rules.deletion
    }
  }

  # Required commit signatures - prevents anti-pattern of unverified commits
  dynamic "rules" {
    for_each = var.rules.required_signatures ? [1] : []
    content {
      required_signatures = var.rules.required_signatures
    }
  }

  # Linear history - prevents merge commits for cleaner monorepo history
  dynamic "rules" {
    for_each = var.rules.required_linear_history ? [1] : []
    content {
      required_linear_history = var.rules.required_linear_history
    }
  }

  # Required deployments before merging
  dynamic "rules" {
    for_each = var.rules.required_deployments ? [1] : []
    content {
      required_deployments {
        required_deployment_environments = ["staging"]
      }
    }
  }

  # Required pull request reviews - supports the "operational excellence" layer
  dynamic "rules" {
    for_each = var.rules.required_reviewers > 0 ? [1] : []
    content {

    }
  }

  # Set up bypass rules for administrators or designated teams
  dynamic "bypass_actors" {
    for_each = var.bypass_actors
    content {
      actor_id    = bypass_actors.value.actor_id
      actor_type  = bypass_actors.value.actor_type
      bypass_mode = bypass_actors.value.bypass_mode
    }
  }

}
