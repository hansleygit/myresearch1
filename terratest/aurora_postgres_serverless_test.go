package test

import (
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestPostgresServerless(t *testing.T) {
	t.Parallel()

	varsFile := "terratest/Scenarios/aurora_postgres_serverless.tfvars"
	applicationName := fmt.Sprintf("tt-aurorapostgres-%s", strings.ToLower(random.UniqueId()))
	appId := fmt.Sprintf("%d", random.Random(10000, 99999))

	tempTestDir := test_structure.CopyTerraformFolderToTemp(t, "..", ".")

	test_structure.RunTestStage(t, "setup_terraform_options", func() {
		terraformOptions := &terraform.Options{
			TerraformDir: tempTestDir,
			VarFiles:     []string{varsFile},
			Vars: map[string]interface{}{
				"application_name": applicationName,
				"app_id":           appId,
			},
			RetryableTerraformErrors: map[string]string{
				"read: connection reset by peer": "Network failure",
				"error updating S3 Bucket":       "Flaky bucket policy",
				"error deleting S3 Bucket":       "Eventual consistenty flakiness",
				"Error deleting S3 policy":       "Flaky bucket policy",
			},
			MaxRetries:         5,
			TimeBetweenRetries: (10 * time.Second),
		}

		test_structure.SaveTerraformOptions(t, tempTestDir, terraformOptions)
	})

	defer test_structure.RunTestStage(t, "teardown", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, tempTestDir)
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy_to_aws", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, tempTestDir)
		terraform.InitAndApply(t, terraformOptions)
	})

}
