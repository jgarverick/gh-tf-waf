package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestLabelsModule(t *testing.T) {
	// Removed unnecessary and incorrect assignment to t

	terraformOptions := &terraform.Options{
		TerraformDir: "../..",
		Vars: map[string]interface{}{
			"repository": "test-repo",
			"labels": map[string]string{
				"bug":     "d73a4a",
				"feature": "a2eeef",
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	labels := terraform.OutputMap(t, terraformOptions, "labels")
	assert.Equal(t, "d73a4a", labels["bug"])
	assert.Equal(t, "a2eeef", labels["feature"])
}
