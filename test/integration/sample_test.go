package samples_test

import (
	"bytes"
	"io/ioutil"
	"os"
	"path"
	"testing"
	"text/template"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
)

const (
	setupPath   = "../setup"
	sampleDir   = "../../"
	logFileName = "test.log"
)

func TestSamples(t *testing.T) {
	// This initial blueprint test is to extract output info
	// so we only have to render the template once as project_id is the same for all tests.
	setup := tft.NewTFBlueprintTest(t,
		tft.WithTFDir(sampleDir),
		tft.WithSetupPath(setupPath),
	)
	providerConfig := renderProviderConfig(t, setup.GetTFSetupStringOutput("project_id"))

	testCases := discoverTestCases(t)
	for _, tc := range testCases {
		t.Run(tc, func(t *testing.T) {
			// write provider config to sample dir
			pth := path.Join(sampleDir, tc)
			cleanUp := createOrOverwriteFile(t, path.Join(pth, "provider.tf"), providerConfig)
			defer cleanUp()

			sampleTest := tft.NewTFBlueprintTest(t,
				tft.WithTFDir(pth),
				tft.WithSetupPath(setupPath),
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

// createOrOverwriteFile creates or overwrites file pth with data.
func createOrOverwriteFile(t *testing.T, pth string, data []byte) func() {
	f, err := os.OpenFile(pth, os.O_RDWR|os.O_CREATE|os.O_TRUNC, 0755)
	if err != nil {
		t.Fatal(err)
	}
	defer f.Close()
	_, err = f.Write(data)
	if err != nil {
		t.Fatal(err)
	}
	return func() { os.Remove(pth) }
}

var providerTmpl = template.Must(template.New("provider").Parse(`provider "google" {
  project     = "{{ .ProjectID }}"
  region      = "us-central1"
  zone        = "us-central1-a"
}
provider "google-beta" {
  project     = "{{ .ProjectID }}"
  region      = "us-central1"
  zone        = "us-central1-a"
}
`))

// renderProviderConfig renders a provider config with projectID.
func renderProviderConfig(t *testing.T, projectID string) []byte {
	var providerConfig bytes.Buffer
	err := providerTmpl.Execute(&providerConfig,
		struct {
			ProjectID string
		}{
			ProjectID: projectID,
		})
	if err != nil {
		t.Fatalf("error rendering provider config: %v", err)
	}
	return providerConfig.Bytes()
}
