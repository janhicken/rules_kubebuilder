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
	"context"
	"fmt"
	admissionv1 "k8s.io/api/admissionregistration/v1"
	authv1 "k8s.io/api/authentication/v1"
	corev1 "k8s.io/api/core/v1"
	rbacv1 "k8s.io/api/rbac/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/types"
	"k8s.io/utils/ptr"
	"time"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
	"sigs.k8s.io/controller-runtime/pkg/client"
)

// namespace where the project is deployed in
const namespace = "project-system"

// serviceAccountName created for the project
const serviceAccountName = "project-controller-manager"

// metricsServiceName is the name of the metrics service of the project
const metricsServiceName = "project-controller-manager-metrics-service"

// metricsRoleBindingName is the name of the RBAC that will be created to allow get the metrics data
const metricsRoleBindingName = "project-metrics-binding"

var _ = Describe("Manager", Ordered, func() {
	var curlPod *corev1.Pod
	var controllerPodName string

	// After all tests have been executed, clean up.
	AfterAll(func(ctx SpecContext) {
		By("cleaning up the curl pod for metrics")
		if curlPod != nil {
			Expect(client.IgnoreNotFound(k8sClient.Delete(ctx, curlPod)))
		}
	})

	SetDefaultEventuallyTimeout(2 * time.Minute)
	SetDefaultEventuallyPollingInterval(time.Second)

	Context("Manager", func() {
		It("should run successfully", func(ctx SpecContext) {
			By("validating that the controller-manager pod is running as expected")
			verifyControllerUp := func(g Gomega) {
				// Get the name of the controller-manager pod
				var pods corev1.PodList
				g.Expect(k8sClient.List(ctx, &pods,
					client.InNamespace(namespace),
					client.MatchingLabels{"control-plane": "controller-manager"},
				)).To(Succeed(), "Failed to retrieve controller-manager pod information")

				g.Expect(pods.Items).To(HaveLen(1), "expected 1 controller pod running")
				pod := pods.Items[0]

				controllerPodName = pod.GetName()
				g.Expect(controllerPodName).To(ContainSubstring("controller-manager"))

				// Validate the pod's status
				g.Expect(pod.Status.Phase).To(Equal(corev1.PodRunning), "Incorrect controller-manager pod status")
			}
			Eventually(verifyControllerUp).Should(Succeed())
		})

		It("should ensure the metrics endpoint is serving metrics", func(ctx SpecContext) {
			By("creating a ClusterRoleBinding for the service account to allow access to metrics")
			metricsRoleBinding := rbacv1.ClusterRoleBinding{
				ObjectMeta: metav1.ObjectMeta{
					Namespace: namespace,
					Name:      metricsRoleBindingName,
				},
				Subjects: []rbacv1.Subject{{
					Kind:      rbacv1.ServiceAccountKind,
					Name:      serviceAccountName,
					Namespace: namespace,
				}},
				RoleRef: rbacv1.RoleRef{
					Kind: "ClusterRole",
					Name: "project-metrics-reader",
				},
			}
			Expect(client.IgnoreAlreadyExists(k8sClient.Create(ctx, &metricsRoleBinding))).
				To(Succeed(), "Failed to create ClusterRoleBinding")

			By("validating that the metrics service is available")
			var service corev1.Service
			Expect(k8sClient.Get(ctx, types.NamespacedName{Name: metricsServiceName, Namespace: namespace}, &service)).
				To(Succeed(), "Metrics service should exist")

			By("validating that the ServiceMonitor for Prometheus is applied in the namespace")
			serviceMonitor := metav1.PartialObjectMetadata{
				TypeMeta: metav1.TypeMeta{
					Kind:       "ServiceMonitor",
					APIVersion: "monitoring.coreos.com/v1",
				},
			}
			serviceMonitorName := types.NamespacedName{Namespace: namespace, Name: "project-controller-manager-metrics-monitor"}
			Expect(k8sClient.Get(ctx, serviceMonitorName, &serviceMonitor)).
				To(Succeed(), "ServiceMonitor should exist")

			By("getting the service account token")
			var token string
			Eventually(func() (string, error) {
				var err error
				token, err = serviceAccountToken(ctx, types.NamespacedName{Namespace: namespace, Name: serviceAccountName})
				return token, err
			}).ShouldNot(BeEmpty(), "failed to create service account token")

			By("waiting for the metrics endpoint to be ready")
			Eventually(func(g Gomega) {
				var endpoints corev1.Endpoints
				g.Expect(k8sClient.Get(ctx, types.NamespacedName{Name: metricsServiceName, Namespace: namespace}, &endpoints)).
					To(Succeed())
				g.Expect(endpoints.Subsets).To(HaveLen(1))
				subset := endpoints.Subsets[0]
				g.Expect(subset.NotReadyAddresses).To(BeEmpty())
			}).Should(Succeed(), "Metrics endpoint is not ready")

			By("creating the curl-metrics pod to access the metrics endpoint")
			curlPod = &corev1.Pod{
				ObjectMeta: metav1.ObjectMeta{
					Namespace: namespace,
					Name:      "curl-metrics",
				},
				Spec: corev1.PodSpec{
					RestartPolicy: corev1.RestartPolicyOnFailure,
					Containers: []corev1.Container{{
						Name:  "curl",
						Image: "curlimages/curl",
						Args: []string{
							"-v",
							"-k",
							"--oauth2-bearer", token,
							fmt.Sprintf("https://%s.%s.svc.cluster.local:8443/metrics", metricsServiceName, namespace),
						},
						SecurityContext: &corev1.SecurityContext{
							AllowPrivilegeEscalation: ptr.To(false),
							Capabilities: &corev1.Capabilities{
								Drop: []corev1.Capability{"ALL"},
							},
							RunAsNonRoot: ptr.To(true),
							RunAsUser:    ptr.To(int64(1000)),
							SeccompProfile: &corev1.SeccompProfile{
								Type: corev1.SeccompProfileTypeRuntimeDefault,
							},
						},
					}},
				},
			}
			Expect(k8sClient.Create(ctx, curlPod)).To(Succeed(), "Failed to create curl-metrics pod")

			By("waiting for the curl-metrics pod to complete.")
			verifyCurlUp := func(g Gomega) {
				curlPodName := types.NamespacedName{Name: curlPod.Name, Namespace: curlPod.Namespace}
				g.Expect(k8sClient.Get(ctx, curlPodName, curlPod)).To(Succeed())
				g.Expect(curlPod.Status.Phase).To(Equal(corev1.PodSucceeded), "curl pod in wrong status")
			}
			Eventually(verifyCurlUp, 5*time.Minute).Should(Succeed())
		})

		It("should provisioned cert-manager", func(ctx SpecContext) {
			By("validating that cert-manager has the certificate Secret")
			verifyCertManager := func() error {
				var certSecret corev1.Secret
				return k8sClient.Get(ctx, types.NamespacedName{Name: "webhook-server-cert", Namespace: namespace}, &certSecret)
			}
			Eventually(verifyCertManager).Should(Succeed())
		})

		It("should have CA injection for mutating webhooks", func(ctx SpecContext) {
			By("checking CA injection for mutating webhooks")
			verifyCAInjection := func(g Gomega) {
				var webhookConfig admissionv1.MutatingWebhookConfiguration
				webhookName := types.NamespacedName{Name: "project-mutating-webhook-configuration", Namespace: namespace}
				g.Expect(k8sClient.Get(ctx, webhookName, &webhookConfig)).To(Succeed())

				g.Expect(webhookConfig.Webhooks).To(HaveLen(1))
				webhook := webhookConfig.Webhooks[0]
				g.Expect(webhook.ClientConfig.CABundle).ToNot(BeEmpty())
			}
			Eventually(verifyCAInjection).Should(Succeed())
		})

		It("should have CA injection for validating webhooks", func(ctx SpecContext) {
			By("checking CA injection for validating webhooks")
			verifyCAInjection := func(g Gomega) {
				var webhookConfig admissionv1.ValidatingWebhookConfiguration
				webhookName := types.NamespacedName{Name: "project-validating-webhook-configuration", Namespace: namespace}
				g.Expect(k8sClient.Get(ctx, webhookName, &webhookConfig)).To(Succeed())

				g.Expect(webhookConfig.Webhooks).To(HaveLen(1))
				webhook := webhookConfig.Webhooks[0]
				g.Expect(webhook.ClientConfig.CABundle).ToNot(BeEmpty())
			}
			Eventually(verifyCAInjection).Should(Succeed())
		})

		// TODO: Customize the e2e test suite with scenarios specific to your project.
		// Consider applying sample/CR(s) and check their status and/or verifying
		// the reconciliation by using the metrics, i.e.:
		// metricsOutput := getMetricsOutput()
		// Expect(metricsOutput).To(ContainSubstring(
		//    fmt.Sprintf(`controller_runtime_reconcile_total{controller="%s",result="success"} 1`,
		//    strings.ToLower(<Kind>),
		// ))
	})
})

// serviceAccountToken returns a token for the specified service account in the given namespace.
// It uses the Kubernetes TokenRequest API to generate a token by directly sending a request
// and parsing the resulting token from the API response.
func serviceAccountToken(ctx context.Context, accountName client.ObjectKey) (string, error) {
	var serviceAccount corev1.ServiceAccount
	if err := k8sClient.Get(ctx, accountName, &serviceAccount); err != nil {
		return "", fmt.Errorf("failed to get service account: %w", err)
	}

	var token authv1.TokenRequest
	if err := k8sClient.SubResource("token").Create(ctx, &serviceAccount, &token); err != nil {
		return "", fmt.Errorf("failed to request token: %w", err)
	}

	return token.Status.Token, nil
}
