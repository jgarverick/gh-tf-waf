package test

import (
	"fmt"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"os"
	"strings"
	"testing"
)

func TestGithubRepositoryModuleBasic(t *testing.T) {
	t.Parallel()

	githubToken := os.Getenv("GITHUB_TOKEN")
	if githubToken == "" {
		t.Skip("GITHUB_TOKEN must be set for acceptance tests")
	}

	repoName := fmt.Sprintf("test-repo-%s", strings.ToLower(random.UniqueId()))

	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"repositories": []map[string]interface{}{
				{
					"name":        repoName,
					"description": "Example repository managed by Terratest",
					"visibility":  "private",
				},
			},
			"billing_email": "test@example.com",
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	actualRepoName := terraform.Output(t, terraformOptions, "project_ids")
	assert.Contains(t, actualRepoName, repoName)

	// Additional assertions
	repoVisibility := terraform.Output(t, terraformOptions, "repo_visibility")
	assert.Contains(t, repoVisibility, "private")

	repoURL := terraform.Output(t, terraformOptions, "repo_urls")
	assert.Contains(t, repoURL, repoName)
}

func TestGithubRepositoryModuleAutoInit(t *testing.T) {
	t.Parallel()

	githubToken := os.Getenv("GITHUB_TOKEN")
	if githubToken == "" {
		t.Skip("GITHUB_TOKEN must be set for acceptance tests")
	}

	repoName := fmt.Sprintf("test-repo-auto-init-%s", strings.ToLower(random.UniqueId()))

	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"repositories": []map[string]interface{}{
				{
					"name":        repoName,
					"description": "Example repository with auto_init managed by Terratest",
					"visibility":  "private",
					"auto_init":   true,
				},
			},
			"billing_email": "test@example.com",
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	actualRepoName := terraform.Output(t, terraformOptions, "project_ids")
	assert.Contains(t, actualRepoName, repoName)

	// Additional assertions for auto_init
	hasReadme := terraform.Output(t, terraformOptions, "has_readme")
	assert.Contains(t, hasReadme, "true")
}

func TestGithubRepositoryModuleWithTemplate(t *testing.T) {
	t.Parallel()

	githubToken := os.Getenv("GITHUB_TOKEN")
	if githubToken == "" {
		t.Skip("GITHUB_TOKEN must be set for acceptance tests")
	}

	// First create a template repository
	templateRepoName := fmt.Sprintf("template-repo-%s", strings.ToLower(random.UniqueId()))
	templateOptions := &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"repositories": []map[string]interface{}{
				{
					"name":        templateRepoName,
					"description": "Template repository managed by Terratest",
					"visibility":  "private",
					"auto_init":   true,
					"is_template": true,
				},
			},
			"billing_email": "test@example.com",
		},
	}

	defer terraform.Destroy(t, templateOptions)
	terraform.InitAndApply(t, templateOptions)

	// Now create a repository from the template
	repoName := fmt.Sprintf("test-from-template-%s", strings.ToLower(random.UniqueId()))
	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"repositories": []map[string]interface{}{
				{
					"name":                repoName,
					"description":         "Repository created from template",
					"visibility":          "private",
					"template_repository": templateRepoName,
					"template_owner":      "current_owner",
					"use_template":        true,
				},
			},
			"billing_email": "test@example.com",
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	actualRepoName := terraform.Output(t, terraformOptions, "project_ids")
	assert.Contains(t, actualRepoName, repoName)
}
