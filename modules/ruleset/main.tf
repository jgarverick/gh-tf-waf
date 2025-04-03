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

  rules {
    creation                = var.rules.creation
    update                  = var.rules.update
    deletion                = var.rules.deletion
    required_signatures     = var.rules.required_signatures
    required_linear_history = var.rules.required_linear_history

    required_deployments {
      required_deployment_environments = ["staging"]
    }
    pull_request {
      required_approving_review_count = var.rules.required_reviewers

      dismiss_stale_reviews_on_push = var.rules.dismiss_stale_reviews
      require_code_owner_review     = var.rules.require_code_owner_review
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
