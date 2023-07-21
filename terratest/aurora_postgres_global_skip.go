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

func TestPostgresGlobal(t *testing.T) {
	t.Parallel()

	varsFile := "terratest/Scenarios/aurora_postgres_global_primary.tfvars"
	applicationName := fmt.Sprintf("tt-aurorapostgres-%s", strings.ToLower(random.UniqueId()))
	appId := fmt.Sprintf("%d", random.Random(10000, 99999))

	tempTestDir := test_structure.CopyTerraformFolderToTemp(t, "..", ".")
	tempTestDir2 := test_structure.CopyTerraformFolderToTemp(t, "..", ".")

	test_structure.RunTestStage(t, "setup_terraform_options", func() {
		terraformOptions := &terraform.Options{
			TerraformDir: tempTestDir,
			VarFiles:     []string{varsFile},
			Vars: map[string]interface{}{
				"application_name": applicationName,
				"app_id":           appId,
				"aws_region":       "us-west-2",
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

	varsFile2 := "terratest/Scenarios/aurora_postgres_global_secondary.tfvars"
	test_structure.RunTestStage(t, "setup_terraform_options", func() {
		terraformOptions2 := &terraform.Options{
			TerraformDir: tempTestDir,
			VarFiles:     []string{varsFile2},
			Vars: map[string]interface{}{
				"application_name": applicationName,
				"app_id":           appId,
				"aws_region":       "us-east-2",
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

		test_structure.SaveTerraformOptions(t, tempTestDir2, terraformOptions2)
	})

	defer test_structure.RunTestStage(t, "teardown", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, tempTestDir2)
		terraform.Destroy(t, terraformOptions)
	})

	defer test_structure.RunTestStage(t, "teardown", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, tempTestDir)
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy_to_aws", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, tempTestDir)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy_to_aws", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, tempTestDir2)
		terraform.InitAndApply(t, terraformOptions)
	})

}
