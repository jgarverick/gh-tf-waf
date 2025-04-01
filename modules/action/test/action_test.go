package test

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestActionModule(t *testing.T) {
	t.Parallel()

	if os.Getenv("GITHUB_TOKEN") == "" {
		t.Skip("GITHUB_TOKEN must be set for acceptance tests")
	}

	// Regular case
	t.Run("ValidInputs", func(t *testing.T) {
		terraformOptions := &terraform.Options{
			TerraformDir: "../", // module root
			Vars: map[string]interface{}{
				"repository":      "example-repo",
				"environment":     "production",
				"secret_name":     "TEST_SECRET",
				"encrypted_value": "encrypted_dummy_value",
			},
		}
		defer terraform.Destroy(t, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)

		secretName := terraform.Output(t, terraformOptions, "secret_name")
		assert.Equal(t, "TEST_SECRET", secretName)
	})

	// Edge case: Missing required variable
	t.Run("MissingRequiredVariable", func(t *testing.T) {
		terraformOptions := &terraform.Options{
			TerraformDir: "../", // module root
			Vars: map[string]interface{}{
				"repository":  "example-repo",
				"environment": "production",
				// Missing "secret_name"
				"encrypted_value": "encrypted_dummy_value",
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
				"repository":      "example-repo",
				"environment":     "production",
				"secret_name":     "",
				"encrypted_value": "encrypted_dummy_value",
			},
		}

		_, err := terraform.InitAndApplyE(t, terraformOptions)
		assert.Error(t, err, "Expected an error when variable value is invalid")
	})
}
