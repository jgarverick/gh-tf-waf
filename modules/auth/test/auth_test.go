package test

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestGithubAuthModuleBasic(t *testing.T) {
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
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Add assertions to validate the configuration
	authStatus := terraform.Output(t, terraformOptions, "auth_status")
	assert.Equal(t, "configured", authStatus)

	ssoUrl := terraform.Output(t, terraformOptions, "saml_sso_url")
	assert.Equal(t, "https://example.com/saml", ssoUrl)
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
