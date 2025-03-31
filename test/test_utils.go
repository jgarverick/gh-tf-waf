package test

import (
	"os"
	"testing"

	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
	"github.com/hashicorp/terraform-plugin-sdk/v2/terraform"
	"github.com/integrations/terraform-provider-github/github"
)

var testAccProviders map[string]*schema.Provider
var testAccProvider *schema.Provider

func init() {
	testAccProvider = github.Provider().(*schema.Provider)
	testAccProviders = map[string]*schema.Provider{
		"github": testAccProvider,
	}
}

func testAccPreCheck(t *testing.T) {
	if os.Getenv("GITHUB_TOKEN") == "" {
		t.Fatal("GITHUB_TOKEN must be set for acceptance tests")
	}
}

// Ensure provider is initialized
func TestProvider(t *testing.T) {
	if err := github.Provider().(*schema.Provider).InternalValidate(); err != nil {
		t.Fatalf("err: %s", err)
	}
}

// Ensure the provider can be configured.
func TestProviderConfigure(t *testing.T) {
	err := testAccProvider.Configure(terraform.NewResourceConfigRaw(map[string]interface{}{
		"token": os.Getenv("GITHUB_TOKEN"),
	}))

	if err != nil {
		t.Fatalf("err: %s", err)
	}
}
