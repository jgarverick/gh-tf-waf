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

func TestOrgModule(t *testing.T) {
	t.Parallel()

	if os.Getenv("GITHUB_TOKEN") == "" {
		t.Skip("GITHUB_TOKEN must be set for acceptance tests")
	}
	if os.Getenv("BILLING_EMAIL") == "" {
		t.Skip("BILLING_EMAIL must be set for acceptance tests")
	}
	// Regular case
	t.Run("ValidInputs", func(t *testing.T) {
		terraformOptions := &terraform.Options{
			TerraformDir: "../", // points to the org module root
			Vars: map[string]interface{}{
				"organization_name": "obliteracy",
			},
		}
		defer terraform.Destroy(t, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	// Edge case: Missing required variable
	t.Run("MissingRequiredVariable", func(t *testing.T) {
		terraformOptions := &terraform.Options{
			TerraformDir: "../", // points to the org module root
			Vars:         map[string]interface{}{
				// Missing "organization_name"
			},
		}
		_, err := terraform.InitAndApplyE(t, terraformOptions)
		assert.Error(t, err, "Expected an error when required variable is missing")
	})

	// Edge case: Invalid variable value
	t.Run("InvalidVariableValue", func(t *testing.T) {
		terraformOptions := &terraform.Options{
			TerraformDir: "../", // points to the org module root
			Vars: map[string]interface{}{
				"organization_name": "",
			},
		}
		_, err := terraform.InitAndApplyE(t, terraformOptions)
		assert.Error(t, err, "Expected an error when variable value is invalid")
	})
}
