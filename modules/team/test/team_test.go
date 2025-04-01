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

func TestTeamModuleBasic(t *testing.T) {
	t.Parallel()

	githubToken := os.Getenv("GITHUB_TOKEN")
	if githubToken == "" {
		t.Skip("GITHUB_TOKEN must be set for acceptance tests")
	}

	teamName := fmt.Sprintf("test-team-%s", strings.ToLower(random.UniqueId()))

	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"teams": []map[string]interface{}{
				{
					"name":        teamName,
					"description": "Test team managed by Terratest",
					"privacy":     "closed",
				},
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Add assertions to validate team creation
	createdTeams := terraform.Output(t, terraformOptions, "team_ids")
	assert.Contains(t, createdTeams, teamName)

	teamPrivacy := terraform.Output(t, terraformOptions, "team_privacy")
	assert.Contains(t, teamPrivacy, "closed")
}

func TestTeamModuleEdgeCases(t *testing.T) {
	t.Parallel()

	githubToken := os.Getenv("GITHUB_TOKEN")
	if githubToken == "" {
		t.Skip("GITHUB_TOKEN must be set for acceptance tests")
	}

	// Edge case: Missing required variable
	t.Run("MissingTeamName", func(t *testing.T) {
		terraformOptions := &terraform.Options{
			TerraformDir: "../",
			Vars: map[string]interface{}{
				"teams": []map[string]interface{}{
					{
						// Missing "name"
						"description": "Test team managed by Terratest",
						"privacy":     "closed",
					},
				},
			},
		}
		_, err := terraform.InitAndApplyE(t, terraformOptions)
		assert.Error(t, err, "Expected an error when required variable is missing")
	})

	// Edge case: Invalid variable value
	t.Run("InvalidTeamPrivacy", func(t *testing.T) {
		teamName := fmt.Sprintf("test-team-invalid-%s", strings.ToLower(random.UniqueId()))
		terraformOptions := &terraform.Options{
			TerraformDir: "../",
			Vars: map[string]interface{}{
				"teams": []map[string]interface{}{
					{
						"name":        teamName,
						"description": "Test team managed by Terratest",
						"privacy":     "invalid-privacy",
					},
				},
			},
		}
		_, err := terraform.InitAndApplyE(t, terraformOptions)
		assert.Error(t, err, "Expected an error when variable value is invalid")
	})
}

func TestTeamWithMembersAndRepositories(t *testing.T) {
	t.Parallel()

	githubToken := os.Getenv("GITHUB_TOKEN")
	if githubToken == "" {
		t.Skip("GITHUB_TOKEN must be set for acceptance tests")
	}

	// First create a repository
	repoName := fmt.Sprintf("team-repo-test-%s", strings.ToLower(random.UniqueId()))
	repoOptions := &terraform.Options{
		TerraformDir: "../../repo",
		Vars: map[string]interface{}{
			"repositories": []map[string]interface{}{
				{
					"name":        repoName,
					"description": "Repository for team access test",
					"visibility":  "private",
					"auto_init":   true,
				},
			},
			"billing_email": "test@example.com",
		},
	}

	defer terraform.Destroy(t, repoOptions)
	terraform.InitAndApply(t, repoOptions)

	// Now create a team with members and repository access
	teamName := fmt.Sprintf("test-team-members-%s", strings.ToLower(random.UniqueId()))

	// Get current user from environment or use a default for test
	currentUser := os.Getenv("GITHUB_USERNAME")
	if currentUser == "" {
		currentUser = "test-user" // This will fail in real tests but allows the test to compile
	}

	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"teams": []map[string]interface{}{
				{
					"name":        teamName,
					"description": "Test team with members and repositories",
					"privacy":     "closed",
					"members":     []string{currentUser},
					"repositories": []map[string]interface{}{
						{
							"name":       repoName,
							"permission": "push",
						},
					},
				},
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Add assertions to validate team with members and repositories
	teamMembers := terraform.Output(t, terraformOptions, "team_members")
	assert.Contains(t, teamMembers, currentUser)

	repoAccess := terraform.Output(t, terraformOptions, "team_repositories")
	assert.Contains(t, repoAccess, repoName)

	permission := terraform.Output(t, terraformOptions, "team_repository_permissions")
	assert.Contains(t, permission, "push")
}
