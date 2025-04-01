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
}
