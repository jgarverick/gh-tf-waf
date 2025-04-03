package test

import (
	"fmt"
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/joho/godotenv"
	"github.com/stretchr/testify/assert"
)

func init() {
	_ = godotenv.Load("../../../.env")
}

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
			"billing_email":     os.Getenv("BILLING_EMAIL"),
			"organization_name": os.Getenv("GITHUB_ORGANIZATION"),
			"teams": []map[string]interface{}{
				{
					"name":        "test-repo-admins",
					"description": "Team with admin access to basic test repositories",
					"privacy":     "closed",
					"repositories": []map[string]interface{}{
						{
							"name":       repoName,
							"permission": "admin",
						},
					},
				},
			},
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
			"billing_email": os.Getenv("BILLING_EMAIL"),
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
			"billing_email":     os.Getenv("BILLING_EMAIL"),
			"organization_name": os.Getenv("GITHUB_ORGANIZATION"),
			"teams": []map[string]interface{}{
				{
					"name":        "template-repo-admins",
					"description": "Team with admin access to template repositories",
					"privacy":     "closed",
					"repositories": []map[string]interface{}{
						{
							"name":       templateRepoName,
							"permission": "admin",
						},
					},
				},
			},
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
			"billing_email":     os.Getenv("BILLING_EMAIL"),
			"organization_name": os.Getenv("GITHUB_ORGANIZATION"),
			"teams": []map[string]interface{}{
				{
					"name":        "template-based-repo-users",
					"description": "Team with write access to template-based repositories",
					"privacy":     "closed",
					"repositories": []map[string]interface{}{
						{
							"name":       repoName,
							"permission": "push",
						},
					},
				},
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	actualRepoName := terraform.Output(t, terraformOptions, "project_ids")
	assert.Contains(t, actualRepoName, repoName)
}

func TestGithubRepositoryModuleEdgeCases(t *testing.T) {
	t.Parallel()

	githubToken := os.Getenv("GITHUB_TOKEN")
	if githubToken == "" {
		t.Skip("GITHUB_TOKEN must be set for acceptance tests")
	}

	// Edge case: Missing required variable
	t.Run("MissingRepositoryName", func(t *testing.T) {
		terraformOptions := &terraform.Options{
			TerraformDir: "../",
			Vars: map[string]interface{}{
				"repositories": []map[string]interface{}{
					{
						// Missing "name"
						"description": "Example repository managed by Terratest",
						"visibility":  "private",
					},
				},
				"billing_email": os.Getenv("BILLING_EMAIL"),
			},
		}
		_, err := terraform.InitAndApplyE(t, terraformOptions)
		assert.Error(t, err, "Expected an error when required variable is missing")
	})

	// Edge case: Invalid variable value
	t.Run("InvalidRepositoryVisibility", func(t *testing.T) {
		repoName := fmt.Sprintf("test-repo-invalid-%s", strings.ToLower(random.UniqueId()))
		terraformOptions := &terraform.Options{
			TerraformDir: "../",
			Vars: map[string]interface{}{
				"repositories": []map[string]interface{}{
					{
						"name":        repoName,
						"description": "Example repository managed by Terratest",
						"visibility":  "invalid-visibility",
					},
				},
				"billing_email": os.Getenv("BILLING_EMAIL"),
			},
		}
		_, err := terraform.InitAndApplyE(t, terraformOptions)
		assert.Error(t, err, "Expected an error when variable value is invalid")
	})
}
