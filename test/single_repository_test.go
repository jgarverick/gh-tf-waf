package test

import (
	"os"
	"testing"

	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/resource"
)

func TestAccGithubRepository_basic(t *testing.T) {
	if os.Getenv("GITHUB_TOKEN") == "" {
		t.Skip("GITHUB_TOKEN must be set for acceptance tests")
	}

	testRepoName := "example-repository" // Ensure this matches the name in your Terraform config

	resource.Test(t, resource.TestCase{
		PreCheck:  func() { testAccPreCheck(t) },
		Providers: testAccProviders,
		Steps: []resource.TestStep{
			{
				Config: testAccGithubRepositoryConfig(testRepoName),
				Check: resource.ComposeTestCheckFunc(
					resource.TestCheckResourceAttr("github_repository.example_repo", "name", testRepoName),
					resource.TestCheckResourceAttr("github_repository.example_repo", "description", "Example repository managed by Terraform"),
					resource.TestCheckResourceAttr("github_repository.example_repo", "visibility", "private"),
					resource.TestCheckResourceAttr("github_repository.example_repo", "has_issues", "true"),
					resource.TestCheckResourceAttr("github_repository.example_repo", "has_projects", "true"),
					resource.TestCheckResourceAttr("github_repository.example_repo", "has_wiki", "false"),
				),
			},
		},
	})
}

func TestAccGithubBranchProtection_basic(t *testing.T) {
	if os.Getenv("GITHUB_TOKEN") == "" {
		t.Skip("GITHUB_TOKEN must be set for acceptance tests")
	}

	testRepoName := "example-repository"

	resource.Test(t, resource.TestCase{
		PreCheck:  func() { testAccPreCheck(t) },
		Providers: testAccProviders,
		Steps: []resource.TestStep{
			{
				Config: testAccGithubRepositoryConfig(testRepoName) + testAccGithubBranchProtectionConfig(testRepoName),
				Check: resource.ComposeTestCheckFunc(
					resource.TestCheckResourceAttr("github_branch_protection.branch_protection", "pattern", "main"),
					resource.TestCheckResourceAttr("github_branch_protection.branch_protection", "required_pull_request_reviews.0.dismiss_stale_reviews", "true"),
					resource.TestCheckResourceAttr("github_branch_protection.branch_protection", "required_pull_request_reviews.0.require_code_owner_reviews", "true"),
					resource.TestCheckResourceAttr("github_branch_protection.branch_protection", "required_pull_request_reviews.0.required_approving_review_count", "1"),
					resource.TestCheckResourceAttr("github_branch_protection.branch_protection", "required_status_checks.0.strict", "true"),
				),
			},
		},
	})
}

func testAccGithubRepositoryConfig(repoName string) string {
	return `
resource "github_repository" "example_repo" {
  name         = "` + repoName + `"
  description  = "Example repository managed by Terraform"
  visibility   = "private"
  has_issues   = true
  has_projects = true
  has_wiki     = false
}
`
}

func testAccGithubBranchProtectionConfig(repoName string) string {
	return `
resource "github_branch_protection" "branch_protection" {
  repository_id = github_repository.example_repo.node_id
  pattern       = "main"

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
    required_approving_review_count = 1
  }

  required_status_checks {
    strict   = true
    contexts = ["ci/test"] # Replace with your CI context
  }

  force_push_bypassers = []
}
`
}
