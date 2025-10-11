package test

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestLabelsModule(t *testing.T) {
	// Skip integration tests in CI unless GITHUB_INTEGRATION_TESTS is explicitly set
	if os.Getenv("CI") == "true" && os.Getenv("GITHUB_INTEGRATION_TESTS") == "" {
		t.Skip("Skipping integration test in CI environment - requires GitHub API write permissions")
	}

	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"repository": "test-repo",
			"labels": map[string]string{
				"bug":     "d73a4a",
				"feature": "a2eeef",
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	labels := terraform.OutputMap(t, terraformOptions, "labels")
	assert.Equal(t, "d73a4a", labels["bug"])
	assert.Equal(t, "a2eeef", labels["feature"])
}
