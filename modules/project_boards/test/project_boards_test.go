package test

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestProjectBoardsModule(t *testing.T) {
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
				"projects": []map[string]interface{}{
					{
						"name":        "Test Project Board",
						"description": "Test project board",
						"readme":      "# Test Board",
						"public":      false,
					},
				},
			},
		}
		defer terraform.Destroy(t, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)

		projectIDs := terraform.Output(t, terraformOptions, "project_ids")
		assert.NotEmpty(t, projectIDs)
	})

	// Edge case: Missing required variable
	t.Run("MissingRequiredVariable", func(t *testing.T) {
		terraformOptions := &terraform.Options{
			TerraformDir: "../", // module root
			Vars: map[string]interface{}{
				// Missing "organization_name"
				"projects": []map[string]interface{}{
					{
						"name":        "Test Project Board",
						"description": "Test project board",
						"readme":      "# Test Board",
						"public":      false,
					},
				},
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
				"projects": []map[string]interface{}{
					{
						"name":        "",
						"description": "Test project board",
						"readme":      "# Test Board",
						"public":      false,
					},
				},
			},
		}
		_, err := terraform.InitAndApplyE(t, terraformOptions)
		assert.Error(t, err, "Expected an error when variable value is invalid")
	})
}
