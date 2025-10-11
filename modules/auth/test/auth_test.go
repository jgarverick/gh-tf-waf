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
			},
		}
		defer terraform.Destroy(t, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)

		samlSsoUrl := terraform.Output(t, terraformOptions, "saml_sso_url")
		assert.Equal(t, "https://example.com/saml", samlSsoUrl)
	})

	// Edge case: Test with minimal variables (all variables have defaults, so this should succeed)
	t.Run("MinimalVariables", func(t *testing.T) {
		terraformOptions := &terraform.Options{
			TerraformDir: "../",
			Vars: map[string]interface{}{
				// Use defaults for all variables
			},
		}
		defer terraform.Destroy(t, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)

		samlSsoUrl := terraform.Output(t, terraformOptions, "saml_sso_url")
		assert.Equal(t, "", samlSsoUrl, "Expected empty string when no value provided")
	})

	// Edge case: Test with OIDC configuration
	t.Run("OIDCConfiguration", func(t *testing.T) {
		terraformOptions := &terraform.Options{
			TerraformDir: "../",
			Vars: map[string]interface{}{
				"oidc_issuer_uri":    "https://example.com/oidc",
				"oidc_client_id":     "client-id-123",
				"oidc_client_secret": "secret-value",
			},
		}
		defer terraform.Destroy(t, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)

		oidcIssuerUri := terraform.Output(t, terraformOptions, "oidc_issuer_uri")
		assert.Equal(t, "https://example.com/oidc", oidcIssuerUri)
	})
}

func TestGithubAuthModuleWithBothSAMLAndOIDC(t *testing.T) {
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
			"oidc_issuer_uri":      "https://example.com/oidc",
			"oidc_client_id":       "client-id-123",
			"oidc_client_secret":   "secret-value",
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Verify both SAML and OIDC outputs
	samlSsoUrl := terraform.Output(t, terraformOptions, "saml_sso_url")
	assert.Equal(t, "https://example.com/saml", samlSsoUrl)

	oidcIssuerUri := terraform.Output(t, terraformOptions, "oidc_issuer_uri")
	assert.Equal(t, "https://example.com/oidc", oidcIssuerUri)
}
