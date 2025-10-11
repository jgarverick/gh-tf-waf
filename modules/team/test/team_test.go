package test

import (
	"fmt"
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/joho/godotenv"
	"github.com/stretchr/testify/assert"
)

func init() {
	_ = godotenv.Load("../../../.env")
}

func TestTeamModuleBasic(t *testing.T) {
	t.Parallel()

	githubToken := os.Getenv("GITHUB_TOKEN")
	if githubToken == "" {
		t.Skip("GITHUB_TOKEN must be set for acceptance tests")
	}

	// Skip integration tests in CI unless GITHUB_INTEGRATION_TESTS is explicitly set
	if os.Getenv("CI") == "true" && os.Getenv("GITHUB_INTEGRATION_TESTS") == "" {
		t.Skip("Skipping integration test in CI environment - requires GitHub API write permissions")
	}

	teamName := fmt.Sprintf("test-team-%s", strings.ToLower(random.UniqueId()))

	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"name":        teamName,
			"description": "Test team managed by Terratest",
			"privacy":     "closed",
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Add assertions to validate team creation
	teamID := terraform.Output(t, terraformOptions, "team_id")
	assert.NotEmpty(t, teamID, "Expected team_id output to contain a valid team ID")

	teamNameOutput := terraform.Output(t, terraformOptions, "team_name")
	assert.Equal(t, teamName, teamNameOutput, "Expected team_name output to match the provided team name")

	teamPrivacy := terraform.Output(t, terraformOptions, "team_privacy")
	assert.Equal(t, "closed", teamPrivacy, "Expected team_privacy output to be 'closed'")
}

func TestTeamModuleEdgeCases(t *testing.T) {
	t.Parallel()

	githubToken := os.Getenv("GITHUB_TOKEN")
	if githubToken == "" {
		t.Skip("GITHUB_TOKEN must be set for acceptance tests")
	}

	// Skip integration tests in CI unless GITHUB_INTEGRATION_TESTS is explicitly set
	if os.Getenv("CI") == "true" && os.Getenv("GITHUB_INTEGRATION_TESTS") == "" {
		t.Skip("Skipping integration test in CI environment - requires GitHub API write permissions")
	}

	// Edge case: Missing required variable
	t.Run("MissingTeamName", func(t *testing.T) {
		terraformOptions := &terraform.Options{
			TerraformDir: "../",
			Vars: map[string]interface{}{
				// Missing "name"
				"description": "Test team managed by Terratest",
				"privacy":     "closed",
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
				"name":        teamName,
				"description": "Test team managed by Terratest",
				"privacy":     "invalid-privacy",
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

	// Skip integration tests in CI unless GITHUB_INTEGRATION_TESTS is explicitly set
	if os.Getenv("CI") == "true" && os.Getenv("GITHUB_INTEGRATION_TESTS") == "" {
		t.Skip("Skipping integration test in CI environment - requires GitHub API write permissions")
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
			"billing_email": os.Getenv("BILLING_EMAIL"),
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
			"name":        teamName,
			"description": "Test team with members and repositories",
			"privacy":     "closed",
			"members":     []string{currentUser},
			"repository_permissions": map[string]string{
				repoName: "push",
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Add assertions to validate team with members and repositories
	teamMembers := terraform.OutputList(t, terraformOptions, "members")
	assert.Contains(t, teamMembers, currentUser)

	// Verify team was created successfully
	teamID := terraform.Output(t, terraformOptions, "team_id")
	assert.NotEmpty(t, teamID, "Expected team_id to be set")
}
