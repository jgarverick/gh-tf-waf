package test

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestRulesetModule(t *testing.T) {
	t.Parallel()

	if os.Getenv("GITHUB_TOKEN") == "" {
		t.Skip("GITHUB_TOKEN must be set for acceptance tests")
	}

	terraformOptions := &terraform.Options{
		TerraformDir: "../", // module root
		Vars: map[string]interface{}{
			"name":        "Test Ruleset",
			"target_type": "organization",
			"enforcement": "active",
			"bypass_actors": []map[string]interface{}{
				{
					"actor_id":    "admin-id",
					"actor_type":  "Team",
					"bypass_mode": "always",
				},
			},
			"rules": map[string]interface{}{
				"creation":                  true,
				"update":                    false,
				"deletion":                  false,
				"required_signatures":       true,
				"required_linear_history":   true,
				"required_deployments":      true,
				"required_reviewers":        1,
				"dismiss_stale_reviews":     true,
				"require_code_owner_review": true,
				"allow_force_pushes":        false,
				"allow_deletions":           false,
			},
			"protected_branches": []string{"main", "develop"},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	protectedBranches := terraform.Output(t, terraformOptions, "protected_branches")
	assert.Contains(t, protectedBranches, "main")
}
