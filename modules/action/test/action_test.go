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
}
