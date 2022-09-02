package samples_test

import (
	"io/ioutil"
	"path"
	"testing"
	"time"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/utils"
)

const (
	setupPath = "../setup"
	sampleDir = "../../"
)

// Retry if these errors are encountered.
var retryErrors = map[string]string{
	// IAM for Eventarc service agent is eventually consistent
	".*Permission denied while using the Eventarc Service Agent.*": "Eventarc Service Agent IAM is eventually consistent",
}

func TestSamples(t *testing.T) {
	// This initial blueprint test is to extract output info
	// so we only have to set the env vars once.
	setup := tft.NewTFBlueprintTest(t,
		tft.WithTFDir(sampleDir),
		tft.WithSetupPath(setupPath),
	)
	testProjectID := setup.GetTFSetupStringOutput("project_id")
	testEnv := map[string]string{
		"GOOGLE_PROJECT": testProjectID,
		"GOOGLE_REGION":  "us-central1",
		"GOOGLE_ZONE":    "us-central1-a",
	}
	for k, v := range testEnv {
		utils.SetEnv(t, k, v)
	}

	testCases := discoverTestCases(t)
	for _, tc := range testCases {
		t.Run(tc, func(t *testing.T) {
			sampleTest := tft.NewTFBlueprintTest(t,
				tft.WithTFDir(path.Join(sampleDir, tc)),
				tft.WithSetupPath(setupPath),
				tft.WithRetryableTerraformErrors(retryErrors, 10, time.Minute),
			)
			sampleTest.Test()
		})
	}
}

// skipDiscoverDirs are directories that are skipped when discovering test cases.
var skipDiscoverDirs = map[string]bool{
	"test":  true,
	"build": true,
	".git":  true,
}

// discoverTestCases discovers individual sample directories in the parent directory.
// It also skips known directories that are not samples.
func discoverTestCases(t *testing.T) []string {
	t.Helper()
	tc := []string{}
	samples, err := ioutil.ReadDir(sampleDir)
	if err != nil {
		t.Fatal(err)
	}
	for _, f := range samples {
		if !f.IsDir() || skipDiscoverDirs[f.Name()] {
			continue
		}
		tc = append(tc, f.Name())
	}
	return tc
}
