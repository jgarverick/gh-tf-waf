package test

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestOrgModule(t *testing.T) {
	t.Parallel()

	if os.Getenv("GITHUB_TOKEN") == "" {
		t.Skip("GITHUB_TOKEN must be set for acceptance tests")
	}

	terraformOptions := &terraform.Options{
		TerraformDir: "../", // points to the org module root
		Vars: map[string]interface{}{
			"organization_name": "test-org",
			// ...existing variables if any...
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
	// ...existing assertions if outputs exist...
}
