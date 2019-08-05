package test

import (
	"fmt"
	"os"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/aws"
	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestS3Website(t *testing.T) {
	t.Parallel()

	// Use a random AWS Region to ensure that the template works on all region
	awsRegion := aws.GetRandomStableRegion(t, nil, nil)

	// set expected website domain that is set to TESTDOMAIN ENV
	expectedDomain := os.Getenv("TESTDOMAIN")

	terraformOptions := &terraform.Options{

		// Path of the terraform example to be used
		TerraformDir: "../examples/s3_website",

		Vars: map[string]interface{}{
			"domain_name":             expectedDomain,
			"index_document":          "index.html",
			"error_document":          "error.html",
			"not_found_path":          "/404.html",
			"not_found_response_code": "404",
			"static_site_tag":         "test",
		},

		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	// at the end of the test, clean up the resource created by the test
	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Verify load balancer response
	maxRetries := 30
	timeBetweenRetries := 5 * time.Second

	// HTTPS url for the tests
	domainUrl := fmt.Sprintf("https://%s", expectedDomain)
	notFoundUrl := fmt.Sprintf("https:/%s/notFoundURL", expectedDomain)

	// Should return 200 and success if it hits index.html
	http_helper.HttpGetWithRetry(t, domainUrl, 200, "Success", maxRetries, timeBetweenRetries)

	// Should return 404 and Not found if it hits 404.html
	http_helper.HttpGetWithRetry(t, notFoundUrl, 404, "Not Found", maxRetries, timeBetweenRetries)
}
