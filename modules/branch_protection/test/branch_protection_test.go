package test

import (
	"fmt"
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestBranchProtectionModuleBasic(t *testing.T) {
	t.Parallel()

	githubToken := os.Getenv("GITHUB_TOKEN")
	if githubToken == "" {
		t.Skip("GITHUB_TOKEN must be set for acceptance tests")
	}

	repoName := fmt.Sprintf("branch-protection-test-%s", strings.ToLower(random.UniqueId()))
	repoOptions := &terraform.Options{
		TerraformDir: "../../repo",
		Vars: map[string]interface{}{
			"repositories": []map[string]interface{}{
				{
					"name":        repoName,
					"description": "A test repository for the branch protection module",
					"private":     true,
				},
			},
		},
	}
	defer terraform.Destroy(t, repoOptions)
	terraform.InitAndApply(t, repoOptions)

	branchProtectionOptions := &terraform.Options{
		TerraformDir: "../../",
		Vars: map[string]interface{}{
			"repository": repoName,
		},
	}
	defer terraform.Destroy(t, branchProtectionOptions)
	terraform.InitAndApply(t, branchProtectionOptions)

	// Add assertions to verify branch protection rules are configured correctly
}

func TestBranchProtectionModuleAdvanced(t *testing.T) {
	t.Parallel()

	githubToken := os.Getenv("GITHUB_TOKEN")
	if githubToken == "" {
		t.Skip("GITHUB_TOKEN must be set for acceptance tests")
	}

	repoName := fmt.Sprintf("branch-adv-protect-%s", strings.ToLower(random.UniqueId()))

	repoOptions := &terraform.Options{
		TerraformDir: "../../repo",
		Vars: map[string]interface{}{
			"repositories": []map[string]interface{}{
				{
					"name":        repoName,
					"description": "Repository for advanced branch protection test",
					"visibility":  "private",
					"auto_init":   true,
				},
			},
			"billing_email": "test@example.com",
		},
	}

	defer terraform.Destroy(t, repoOptions)
	terraform.InitAndApply(t, repoOptions)

	// Apply advanced branch protection rules
	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"repository_name":        repoName,
			"branch_patterns":        []string{"main", "release/*"},
			"enforce_admins":         true,
			"required_checks":        []string{"lint", "test", "security-scan"},
			"required_reviews":       2,
			"dismiss_stale_reviews":  true,
			"restrict_pushes":        true,
			"allow_force_pushes":     false,
			"allow_deletions":        false,
			"require_signed_commits": true,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Add assertions for advanced settings
	signedCommits := terraform.Output(t, terraformOptions, "require_signed_commits")
	assert.Equal(t, "true", signedCommits)

	allowDeletions := terraform.Output(t, terraformOptions, "allow_deletions")
	assert.Equal(t, "false", allowDeletions)

	protectedPatterns := terraform.Output(t, terraformOptions, "protected_patterns")
	assert.Contains(t, protectedPatterns, "main")
	assert.Contains(t, protectedPatterns, "release/*")
}

func TestBranchProtectionModuleEdgeCases(t *testing.T) {
	t.Parallel()

	githubToken := os.Getenv("GITHUB_TOKEN")
	if githubToken == "" {
		t.Skip("GITHUB_TOKEN must be set for acceptance tests")
	}

	// Edge case: Missing required variable
	t.Run("MissingRepository", func(t *testing.T) {
		branchProtectionOptions := &terraform.Options{
			TerraformDir: "../../",
			Vars:         map[string]interface{}{
				// Missing "repository"
			},
		}
		_, err := terraform.InitAndApplyE(t, branchProtectionOptions)
		assert.Error(t, err, "Expected an error when required variable is missing")
	})

	// Edge case: Invalid variable value
	t.Run("InvalidBranchPattern", func(t *testing.T) {
		branchProtectionOptions := &terraform.Options{
			TerraformDir: "../../",
			Vars: map[string]interface{}{
				"repository":      "test-repo",
				"branch_patterns": []string{"*invalid*pattern"},
			},
		}
		_, err := terraform.InitAndApplyE(t, branchProtectionOptions)
		assert.Error(t, err, "Expected an error when branch pattern is invalid")
	})
}
