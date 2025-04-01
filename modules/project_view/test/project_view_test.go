package test

import (
	"os"
	"strconv"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestProjectViewModule(t *testing.T) {
	t.Parallel()

	if os.Getenv("GITHUB_TOKEN") == "" {
		t.Skip("GITHUB_TOKEN must be set for acceptance tests")
	}

	// Regular case
	t.Run("ValidInputs", func(t *testing.T) {
		terraformOptions := &terraform.Options{
			TerraformDir: "../", // module root
			Vars: map[string]interface{}{
				"organization_name": "test-org",
				"project_number":    1,
				"views":             []map[string]interface{}{},
				"default_view_name": "Default View",
				"enable_automation": false,
			},
		}
		defer terraform.Destroy(t, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)

		projectURL := terraform.Output(t, terraformOptions, "project_url")
		assert.Contains(t, projectURL, "test-org")
		assert.Contains(t, projectURL, strconv.Itoa(1))
	})

	// Edge case: Missing required variable
	t.Run("MissingRequiredVariable", func(t *testing.T) {
		terraformOptions := &terraform.Options{
			TerraformDir: "../", // module root
			Vars: map[string]interface{}{
				// Missing "organization_name"
				"project_number":    1,
				"views":             []map[string]interface{}{},
				"default_view_name": "Default View",
				"enable_automation": false,
			},
		}
		_, err := terraform.InitAndApplyE(t, terraformOptions)
		assert.Error(t, err, "Expected an error when required variable is missing")
	})

	// Edge case: Invalid variable value
	t.Run("InvalidVariableValue", func(t *testing.T) {
		terraformOptions := &terraform.Options{
			TerraformDir: "../", // module root
			Vars: map[string]interface{}{
				"organization_name": "test-org",
				"project_number":    -1, // Invalid project number
				"views":             []map[string]interface{}{},
				"default_view_name": "Default View",
				"enable_automation": false,
			},
		}
		_, err := terraform.InitAndApplyE(t, terraformOptions)
		assert.Error(t, err, "Expected an error when variable value is invalid")
	})
}
