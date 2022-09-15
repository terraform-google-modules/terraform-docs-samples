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

// testGroups represents a collection of samples matched to a projectID.
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
	// common test env
	testEnv := map[string]string{
		"GOOGLE_REGION": "us-central1",
		"GOOGLE_ZONE":   "us-central1-a",
	}
	for k, v := range testEnv {
		utils.SetEnv(t, k, v)
	}

	// This initial blueprint test is to extract output info
	// so we only have to set the env vars once.
	setup := tft.NewTFBlueprintTest(t,
		tft.WithTFDir(sampleDir),
		tft.WithSetupPath(setupPath),
	)
	testProjectIDs := setup.GetTFSetupOutputListVal("project_ids")
	// number of groups is determined by length of testProjectIDs slice
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

// discoverTestCaseGroups discovers individual sample directories in the parent directory
// and assigns them to a test group based on projects provided.
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

	// One test group is associated to one project.
	groups := []*testGroups{}
	for i, project := range projects {
		groups = append(groups, &testGroups{projectID: project, samples: []string{}, group: i})
	}
	// Rather than chunking we assign them in a round robin fashion as some samples like sql takes more time.
	// Chunking would result in all sql* assigned to a single project.
	// We sort the sample slice beforehand so assignments should be stable for a given run.
	for i, sample := range samples {
		groupIndex := i % len(projects)
		groups[groupIndex].samples = append(groups[groupIndex].samples, sample)
	}
	return groups
}
