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

func TestGithubAuthModuleBasic(t *testing.T) {
	t.Parallel()

	githubToken := os.Getenv("GITHUB_TOKEN")
	if githubToken == "" {
		t.Skip("GITHUB_TOKEN must be set for acceptance tests")
	}

	// Regular case
	t.Run("ValidInputs", func(t *testing.T) {
		terraformOptions := &terraform.Options{
			TerraformDir: "../",
			Vars: map[string]interface{}{
				"saml_sso_url":         "https://example.com/saml",
				"saml_issuer_url":      "https://example.com",
				"saml_idp_certificate": "certificate",
				"auth_status":          "configured", // Added expected output for validation
			},
		}
		defer terraform.Destroy(t, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)

		authStatus := terraform.Output(t, terraformOptions, "auth_status")
		assert.Equal(t, "configured", authStatus)
	})

	// Edge case: Missing required variable
	t.Run("MissingRequiredVariable", func(t *testing.T) {
		terraformOptions := &terraform.Options{
			TerraformDir: "../",
			Vars: map[string]interface{}{
				"saml_issuer_url":      "https://example.com",
				"saml_idp_certificate": "certificate",
				// Missing "saml_sso_url"
			},
		}
		_, err := terraform.InitAndApplyE(t, terraformOptions)
		assert.Error(t, err, "Expected an error when required variable is missing")
	})

	// Edge case: Invalid variable value
	t.Run("InvalidVariableValue", func(t *testing.T) {
		terraformOptions := &terraform.Options{
			TerraformDir: "../",
			Vars: map[string]interface{}{
				"saml_sso_url":         "invalid-url",
				"saml_issuer_url":      "https://example.com",
				"saml_idp_certificate": "certificate",
				"auth_status":          "error", // Added expected output for validation
			},
		}
		_, err := terraform.InitAndApplyE(t, terraformOptions)
		assert.Error(t, err, "Expected an error when variable value is invalid")
	})
}

func TestGithubAuthModuleWithRBAC(t *testing.T) {
	t.Parallel()

	githubToken := os.Getenv("GITHUB_TOKEN")
	if githubToken == "" {
		t.Skip("GITHUB_TOKEN must be set for acceptance tests")
	}

	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"saml_sso_url":         "https://example.com/saml",
			"saml_issuer_url":      "https://example.com",
			"saml_idp_certificate": "certificate",
			"enable_rbac":          true,
			"admin_roles":          []string{"Administrators", "SecurityOfficers"},
			"viewer_roles":         []string{"Developers", "Viewers"},
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Add assertions for RBAC configuration
	rbacEnabled := terraform.Output(t, terraformOptions, "rbac_enabled")
	assert.Equal(t, "true", rbacEnabled)

	adminRoles := terraform.Output(t, terraformOptions, "admin_roles")
	assert.Contains(t, adminRoles, "Administrators")
	assert.Contains(t, adminRoles, "SecurityOfficers")
}
