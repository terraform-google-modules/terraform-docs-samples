package samples_test

import (
	"fmt"
	"io/ioutil"
	"path"
	"sort"
	"testing"
	"time"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/utils"
)

const (
	setupPath = "../setup"
	sampleDir = "../../"
)

type testGroups struct {
	projectID string
	group     int
	samples   []string
}

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
	testProjectIDs := setup.GetTFSetupOutputListVal("project_ids")
	testEnv := map[string]string{
		"GOOGLE_REGION": "us-central1",
		"GOOGLE_ZONE":   "us-central1-a",
	}
	for k, v := range testEnv {
		utils.SetEnv(t, k, v)
	}

	testGroups := discoverTestCaseGroups(t, testProjectIDs)
	for _, tg := range testGroups {
		for _, sample := range tg.samples {
			testName := fmt.Sprintf("%d/%s", tg.group, sample)
			t.Run(testName, func(t *testing.T) {
				utils.SetEnv(t, "GOOGLE_PROJECT", tg.projectID)
				sampleTest := tft.NewTFBlueprintTest(t,
					tft.WithTFDir(path.Join(sampleDir, sample)),
					tft.WithSetupPath(setupPath),
					tft.WithRetryableTerraformErrors(retryErrors, 10, time.Minute),
				)
				sampleTest.Test()
			})
		}
	}
}

// skipDiscoverDirs are directories that are skipped when discovering test cases.
var skipDiscoverDirs = map[string]bool{
	"test":  true,
	"build": true,
	".git":  true,
}

// discoverTestCaseGroups discovers individual sample directories in the parent directory.
// It also skips known directories that are not samples.
func discoverTestCaseGroups(t *testing.T, projects []string) []*testGroups {
	t.Helper()
	samples := []string{}
	dirs, err := ioutil.ReadDir(sampleDir)
	if err != nil {
		t.Fatal(err)
	}
	for _, f := range dirs {
		if !f.IsDir() || skipDiscoverDirs[f.Name()] {
			continue
		}
		samples = append(samples, f.Name())
	}
	sort.Strings(samples)
	sampleLen := len(samples)
	t.Logf("discovered %d samples", sampleLen)

	tcs := []*testGroups{}
	for i, project := range projects {
		tcs = append(tcs, &testGroups{projectID: project, samples: []string{}, group: i})
	}
	for i, sample := range samples {
		idx := i % len(projects)
		tcs[idx].samples = append(tcs[idx].samples, sample)
	}
	return tcs
}
