package test

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestEnterpriseModule(t *testing.T) {
	t.Parallel()

	if os.Getenv("GITHUB_TOKEN") == "" {
		t.Skip("GITHUB_TOKEN must be set for acceptance tests")
	}

	// Regular case
	t.Run("ValidInputs", func(t *testing.T) {
		terraformOptions := &terraform.Options{
			TerraformDir: "../", // points to the enterprise module root
			Vars: map[string]interface{}{
				"name":           "test-enterprise",
				"description":    "Test Enterprise",
				"administrators": []string{},
				"github_token":   os.Getenv("GITHUB_TOKEN"),
				"billing_email":  "test@example.com",
				"location":       "US",
				"admin_logins":   []string{"test-admin"},
				"enterprise_id":  "ENT-12345",
			},
		}
		defer terraform.Destroy(t, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)

		enterpriseID := terraform.Output(t, terraformOptions, "enterprise_id")
		assert.Equal(t, "ENT-12345", enterpriseID)
	})

	// Edge case: Missing required variable
	t.Run("MissingRequiredVariable", func(t *testing.T) {
		terraformOptions := &terraform.Options{
			TerraformDir: "../", // points to the enterprise module root
			Vars: map[string]interface{}{
				"description":    "Test Enterprise",
				"administrators": []string{},
				"github_token":   os.Getenv("GITHUB_TOKEN"),
				"billing_email":  "test@example.com",
				"location":       "US",
				"admin_logins":   []string{"test-admin"},
				// Missing "name"
			},
		}
		_, err := terraform.InitAndApplyE(t, terraformOptions)
		assert.Error(t, err, "Expected an error when required variable is missing")
	})

	// Edge case: Invalid variable value
	t.Run("InvalidVariableValue", func(t *testing.T) {
		terraformOptions := &terraform.Options{
			TerraformDir: "../", // points to the enterprise module root
			Vars: map[string]interface{}{
				"name":           "test-enterprise",
				"description":    "Test Enterprise",
				"administrators": []string{},
				"github_token":   os.Getenv("GITHUB_TOKEN"),
				"billing_email":  "invalid-email",
				"location":       "US",
				"admin_logins":   []string{"test-admin"},
				"enterprise_id":  "ENT-12345",
			},
		}
		_, err := terraform.InitAndApplyE(t, terraformOptions)
		assert.Error(t, err, "Expected an error when variable value is invalid")
	})
}
