package test

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/joho/godotenv"
	"github.com/stretchr/testify/assert"
)

func init() {
	_ = godotenv.Load("../../../.env")
}

func TestCopilotModuleBasic(t *testing.T) {
	t.Parallel()

	githubToken := os.Getenv("GITHUB_TOKEN")
	if githubToken == "" {
		t.Skip("GITHUB_TOKEN must be set for acceptance tests")
	}

	// Skip integration tests in CI unless GITHUB_INTEGRATION_TESTS is explicitly set
	if os.Getenv("CI") == "true" && os.Getenv("GITHUB_INTEGRATION_TESTS") == "" {
		t.Skip("Skipping integration test in CI environment - requires GitHub API write permissions")
	}

	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"governance_repository_name":  "copilot-governance-test",
			"visibility":                  "private",
			"copilot_usage_workflow_path": "../../../templates/workflows/copilot_usage_report.yml",
			"copilot_team_id":             "",
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	repoName := terraform.Output(t, terraformOptions, "governance_repository_name")
	assert.Equal(t, "copilot-governance-test", repoName)

	repoURL := terraform.Output(t, terraformOptions, "governance_repository_url")
	assert.Contains(t, repoURL, "copilot-governance-test")
}

func TestCopilotModuleDefaultLabels(t *testing.T) {
	t.Parallel()

	githubToken := os.Getenv("GITHUB_TOKEN")
	if githubToken == "" {
		t.Skip("GITHUB_TOKEN must be set for acceptance tests")
	}

	// Skip integration tests in CI unless GITHUB_INTEGRATION_TESTS is explicitly set
	if os.Getenv("CI") == "true" && os.Getenv("GITHUB_INTEGRATION_TESTS") == "" {
		t.Skip("Skipping integration test in CI environment - requires GitHub API write permissions")
	}

	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"governance_repository_name":  "copilot-governance-labels-test",
			"visibility":                  "private",
			"copilot_usage_workflow_path": "../../../templates/workflows/copilot_usage_report.yml",
			"copilot_team_id":             "",
			// Use default labels
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	repoName := terraform.Output(t, terraformOptions, "governance_repository_name")
	assert.Equal(t, "copilot-governance-labels-test", repoName)
}

func TestCopilotModuleInvalidVisibility(t *testing.T) {
	t.Parallel()

	githubToken := os.Getenv("GITHUB_TOKEN")
	if githubToken == "" {
		t.Skip("GITHUB_TOKEN must be set for acceptance tests")
	}

	// Skip integration tests in CI unless GITHUB_INTEGRATION_TESTS is explicitly set
	if os.Getenv("CI") == "true" && os.Getenv("GITHUB_INTEGRATION_TESTS") == "" {
		t.Skip("Skipping integration test in CI environment - requires GitHub API write permissions")
	}

	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"governance_repository_name":  "copilot-governance-invalid-test",
			"visibility":                  "invalid-visibility",
			"copilot_usage_workflow_path": "../../../templates/workflows/copilot_usage_report.yml",
		},
	}

	_, err := terraform.InitAndApplyE(t, terraformOptions)
	assert.Error(t, err, "Expected an error when visibility value is invalid")
	assert.Contains(t, err.Error(), "visibility", "Expected error to reference the invalid visibility value")
}
