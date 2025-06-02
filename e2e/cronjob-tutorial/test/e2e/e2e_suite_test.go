/*
Copyright 2025 The Kubernetes authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package e2e

import (
	"fmt"
	"io"
	"os"
	"testing"
	"time"

	"tutorial.kubebuilder.io/project/test/utils"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
	"sigs.k8s.io/controller-runtime/pkg/client"
)

const (
	ConfigFileEnv       = "CONFIG_FILE"
	ControlllerImageEnv = "CONTROLLER_IMAGE_TARBALL"
	kindClusterName     = "cronjob-tutorial-e2e"
)

var (
	kindEnv   *utils.KindEnvironment
	k8sClient client.Client
)

// TestE2E runs the end-to-end (e2e) test suite for the project. These tests execute in an isolated,
// temporary environment to validate project changes with the purposed to be used in CI jobs.
// The default setup requires Kind, builds/loads the Manager Docker image locally, and installs
// CertManager.
func TestE2E(t *testing.T) {
	RegisterFailHandler(Fail)
	_, _ = fmt.Fprintf(GinkgoWriter, "Starting project integration test suite\n")
	RunSpecs(t, "e2e suite")
}

var _ = BeforeSuite(func(ctx SpecContext) {
	controllerImage, ok := os.LookupEnv(ControlllerImageEnv)
	Expect(ok).To(BeTrue(), "Missing environment variable: %q", ControlllerImageEnv)
	GinkgoLogr.Info("Using controller image tarball", "path", controllerImage)

	configFilePath, ok := os.LookupEnv(ConfigFileEnv)
	Expect(ok).To(BeTrue(), "Missing environment variable: %q", ConfigFileEnv)
	GinkgoLogr.Info("Using config file", "path", configFilePath)

	controllerImageFile, err := os.Open(controllerImage)
	Expect(err).ToNot(HaveOccurred(), "failed to open controller image tarball")
	defer func(file *os.File) {
		Expect(file.Close()).To(Succeed(), "failed to close controller image tarball")
	}(controllerImageFile)

	kindEnv, err = utils.NewKindEnvironment(kindClusterName, 1*time.Minute, []io.Reader{controllerImageFile})
	Expect(err).ToNot(HaveOccurred(), "failed to create Kind cluster")
	restCfg, err := kindEnv.GetClientConfig()
	Expect(err).ToNot(HaveOccurred(), "failed to create kind cluster client config")

	kubeHelper, err := utils.NewKubeHelper(restCfg)
	Expect(err).ToNot(HaveOccurred(), "failed to create KubeHelper")
	Expect(kubeHelper.Apply(ctx, configFilePath)).To(Succeed(), "failed to apply config")

	k8sClient = kubeHelper.GetClient()
})

var _ = AfterSuite(func() {
	By("Shutting down the Kind cluster")
	Expect(kindEnv.Shutdown()).To(Succeed())
})
