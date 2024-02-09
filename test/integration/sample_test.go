// Copyright 2022 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package samples_test

import (
	"fmt"
	"io/fs"
	"path/filepath"
	"sort"
	"strings"
	"testing"
	"time"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/utils"
	"github.com/stretchr/testify/assert"
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
	// API activation is eventually consistent.
	".*SERVICE_DISABLED.*": "Service enablement is eventually consistent",
	// Retry function GCS access
	".*does not have storage.objects.get access.*": "GCS IAM is eventually consistent",
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
		for _, samplePath := range tg.samples {
			sampleName := filepath.Base(samplePath)
			testName := fmt.Sprintf("%d/%s", tg.group, sampleName)
			t.Run(testName, func(t *testing.T) {
				t.Parallel()

				utils.SetEnv(t, "GOOGLE_PROJECT", tg.projectID)
				t.Logf("Test %s running %s project", sampleName, tg.projectID)
				sampleTest := tft.NewTFBlueprintTest(t,
					tft.WithTFDir(samplePath),
					tft.WithSetupPath(setupPath),
					tft.WithRetryableTerraformErrors(retryErrors, 10, time.Minute),
				)
				sampleTest.DefineVerify(func(a *assert.Assertions) {})
				sampleTest.Test()
				t.Logf("Test %s completed in %s project", sampleName, tg.projectID)
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

	// skip any dirs with root in skipDiscoverDirs
	skipDirs := func(f fs.FileInfo) bool {
		rootDir := strings.SplitN(f.Name(), "/", 2)[0]
		return skipDiscoverDirs[rootDir]
	}
	samples, err := walkTerraformDirs(sampleDir, skipDirs)
	if err != nil {
		t.Fatal(err)
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

// replace with https://github.com/GoogleCloudPlatform/cloud-foundation-toolkit/blob/1554af3ba2093bb02301ccd7061606011c82d9bc/cli/util/file.go#L17
// after https://github.com/GoogleCloudPlatform/cloud-foundation-toolkit/pull/1279
const (
	tfInternalDirPrefix = ".terraform"
)

// walkTerraformDirs traverses a provided path to return a list of directories
// that hold terraform configs while skiping internal folders that have a
// .terraform.* prefix
func walkTerraformDirs(topLevelPath string, skip func(fs.FileInfo) bool) ([]string, error) {
	var tfDirs []string
	err := filepath.Walk(topLevelPath, func(path string, info fs.FileInfo, err error) error {
		if err != nil {
			return fmt.Errorf("failure in accessing the path %q: %v", path, err)
		}
		if skip(info) {
			return filepath.SkipDir
		}
		if info.IsDir() && strings.HasPrefix(info.Name(), tfInternalDirPrefix) {
			return filepath.SkipDir
		}

		if !info.IsDir() && strings.HasSuffix(info.Name(), ".tf") {
			tfDirs = append(tfDirs, filepath.Dir(path))
			return filepath.SkipDir
		}

		return nil
	})
	if err != nil {
		return nil, fmt.Errorf("error walking the path %q: %v", topLevelPath, err)
	}

	return tfDirs, nil
}
